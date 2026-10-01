# Known Issues — OP13-OCVM Patched (v61.82-patched for C.93)

## ⚠️ Master Mode Crash (`0x8009`)

**Status:** OPEN — Chưa có fix khả thi  
**Mức độ:** Camera văng app khi chuyển sang Master Mode  
**Ảnh hưởng:** Chỉ Master Mode. Tất cả các chế độ khác (Chụp thường, Video, Chân dung, v.v.) hoạt động bình thường.

### Nguyên nhân gốc (Root Cause)

Crash xảy ra tại `camera.oemlayer.so` (file hệ thống gốc C.93), hàm `OemLayer::MultiCamUsecase::UpdateRTConfigStream` tại offset `0xd0cd0`.

**Chi tiết kỹ thuật:**
- Khi Master Mode (`operation_mode = 0x8009`) được kích hoạt, `camera.oemlayer.so` kiểm tra `EnableOfflineFeatureList` trong `CameraHWConfiguration.config`.
- Vì `0x8009` nằm trong danh sách, hệ thống định tuyến (route) luồng xử lý qua `RealtimeCamera3Device::ConfigStreams` → `MultiCamUsecase::UpdateRTConfigStream`.
- Hàm này truy cập một `std::map` tại offset `0x3128` để tìm stream metadata cho Physical Camera ID 0 (Main sensor).
- File mod `com.qti.chi.override.so` (build trên nền firmware khác, không phải C.93) không cung cấp entry cho Camera 0 trong map này. Map chỉ chứa Camera 2 (UW), 3 (Tele), 4 (Tele2).
- `std::map::operator[]` tự tạo entry mặc định với null pointer → `ldr w20, [x8]` đọc địa chỉ `0x0` → **SIGSEGV**.

### Các hướng đã thử và kết quả

| # | Phương pháp | Kết quả |
|---|---|---|
| 1 | Xóa `0x8009` khỏi `EnableOfflineFeatureList` | Master Mode không crash nhưng **đen thui** (stream không được thiết lập) |
| 2 | Vô hiệu hóa `libAlgoProcess.so` của X8U Add-on | Camera **liệt hoàn toàn** ở mọi chế độ (file này là "nhạc trưởng" bắt buộc) |
| 3 | Dùng bản git v70 (quyetbkhoa/OP13-OCVM) | Crash tương tự tại cùng vị trí (cùng root cause) |

### Hướng fix tiềm năng (chưa thực hiện)

1. **Binary patch `com.qti.chi.override.so`:** Chỉnh sửa mã máy để file mod cung cấp đúng stream metadata cho Camera 0 khi ở Master Mode. Yêu cầu tìm được file gốc (base) mà UltraM8 đã dùng để mod.
2. **Binary patch `camera.oemlayer.so`:** Thêm null-check trước khi truy cập map entry cho Camera 0 (thay `ldr w20, [x8]` bằng `cbz x8, <skip>` + fallback). Rủi ro cao, cần kiến thức ARM64 assembly chuyên sâu.
3. **Chờ UltraM8 ra bản mới:** Tác giả cập nhật file mod tương thích với C.93.

---

## ⚠️ Master Mode Capture Crash (EXIF `stoi: out of range`)

**Status:** OPEN — Liên quan đến Add-on X8U  
**Mức độ:** Nếu Master Mode được fix ở trên, sẽ crash lần nữa **sau khi bấm chụp**  
**Ảnh hưởng:** Chỉ Master Mode capture.

### Nguyên nhân

File `libAlgoProcess.so` trong Add-on X8U (từ Find X8 Ultra) crash khi ghi dữ liệu EXIF vào ảnh JPEG ở Master Mode. Hàm `APSParamsHolder::get<int>` gọi `std::stoi` với một chuỗi giá trị EXIF không nằm trong phạm vi `int` → exception `St12out_of_range` → **SIGABRT**.

**Backtrace:**
```
#08 libAlgoProcess.so — APSParamsHolder::get<int>
#09 libAlgoProcess.so — fillJpegExifData
#10 libAlgoProcess.so — rewriteExifDataInJpeg
#11 libAlgoProcess.so — jpegCodecProcess
```

### Ghi chú

Không thể vô hiệu hóa riêng `libAlgoProcess.so` vì nó là "nhạc trưởng" điều phối toàn bộ post-processing pipeline (HybridRaw, HDR, Portrait...). Thiếu nó, camera không hoạt động.

---

## ✅ Đã fix: KernelSU Install Script Error

**Status:** FIXED  
**Mô tả:** Module sử dụng MMT Extended installer. Khi cài qua `ksud module install`, script `customize.sh` không tìm thấy `functions.sh` tại `/dev/tmp/` → lỗi `can't open '/dev/tmp/functions.sh'`.  
**Fix:** Cài đặt thủ công bằng cách copy trực tiếp vào `/data/adb/modules/` và phân quyền bằng tay.

---

## Môi trường test

- **Thiết bị:** OnePlus 13 (CPH2649 / OP5D55L1)
- **ROM:** ColorOS 16, Build C.93 (`BP2A.250605.015`)
- **Root:** KernelSU
- **Module chính:** OP13-OCVM v61.82-patched
- **Add-on:** UM8s OP13 CAM blobaddon v3.97
