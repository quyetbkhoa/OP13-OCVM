# Issue Tracking & Changelog — OP13-OCVM

## ✅ [RESOLVED in v80] Master Mode Crash (`0x8009` at `camera.oemlayer.so`)

**Status:** RESOLVED in v80  
**Nguyên nhân:** File mod cũ thay thế `system/vendor/lib64/hw/com.qti.chi.override.so` không tương thích với firmware ColorOS 16 C.93 / 501, khiến luồng stream metadata cho Physical Camera 0 bị thiếu trong `std::map`, dẫn đến null pointer dereference (`ldr w20, [x8]` tại offset `0xd0cd0`). Đồng thời section `[OemSupportedCustomInfoSizes0]` trong `CameraHWConfiguration.config` bị mod ép kích thước đệm ảo `8192X6144` vào chế độ thường (`8001`), làm crash `ChiFeature2RealTimeMCX` (`0x41fcc`).  
**Khắc phục:** 
1. Loại bỏ toàn bộ `system/vendor` khỏi module để hệ thống sử dụng Qualcomm CamX Vendor HAL gốc của ROM.
2. Khôi phục kích thước đệm tiêu chuẩn trong `CameraHWConfiguration.config` cho chế độ `8001`. Master Mode `0x8009` hoạt động mượt mà và ổn định.

---

## ✅ [RESOLVED in v80] Master Mode Capture Crash (`stoi: out of range` in `libAlgoProcess.so`)

**Status:** RESOLVED in v80  
**Nguyên nhân:** Addon cũ (v3.97) sử dụng `libAlgoProcess.so` 4.9MB từ nền tảng ColorOS 15 cũ. Khi chạy trên ColorOS 16, hàm `APSParamsHolder::get<int>` bị tràn số nguyên 32-bit trong chuỗi EXIF khi ghi dữ liệu JPEG, phát sinh ngoại lệ `std::out_of_range` làm crash SIGABRT.  
**Khắc phục:** Cập nhật toàn bộ 52 thư viện ODM hậu kỳ trong Addon lên phiên bản native ColorOS 16 build 501 (trích xuất bit-for-bit từ Find X8 Ultra 501, `libAlgoProcess.so` 6.58MB). Xử lý ảnh và lưu EXIF hoàn toàn trơn tru.

---

## ✅ [RESOLVED in v80] Camera App Launch Freeze / 0 Cameras Detected

**Status:** RESOLVED in v80  
**Nguyên nhân:** Quá trình port vô tình đưa các tệp driver thanh ghi cảm biến và ma trận phần cứng vật lý của Find X8 Ultra (`com.qti.sensorsocmap.socid_map.bin`, `com.qti.sensor.zf*.so`, `eeprom_zf*.bin`, `self_ois.ocfg`, `oplus_eis_camera.vcfg`) vào module. Vì X8U sử dụng cảm biến LYT-900 (1 inch) và lăng kính chống rung kép, còn OnePlus 13 sử dụng cảm biến LYT-808 (1/1.4") và driver `dodgemain`, Qualcomm CamX không tìm thấy phần cứng tương thích nên báo `Number of camera devices: 0`, dẫn đến ứng dụng camera bị treo đen màn hình (ANR).  
**Khắc phục:** Tách bạch triệt để giữa tầng phần cứng (Hardware Sensor Driver) và tầng xử lý ảnh (Image Processing Pipeline):
1. Giữ nguyên 100% driver phần cứng gốc của OnePlus 13 (`dodgemain`, `socid_map.bin`, OIS).
2. Tích hợp 100% toàn bộ pipeline thuật toán hậu kỳ của Find X8 Ultra 501 (930/935 tệp thuật toán, bao gồm Dual Portrait Hasselblad, ArcSoft RAW Turbo HDR 147MB, model FDC chống méo mặt góc rộng 17MB, Vega face tracking, NPU Hexagon binaries, và toàn bộ LUT màu phim Hasselblad).

---

## Môi trường xác nhận thực tế (v80 Verified)

- **Thiết bị:** OnePlus 13 (CPH2649 / OP5D55L1)
- **ROM:** ColorOS 16, Build C.93 (`BP2A.250605.015`) / 16.0.10.501
- **Root:** KernelSU
- **Module chính:** OP13-OCVM v80
- **Add-on:** FX8U Camera Processing For OP13 v80
- **Kết quả:** Viewfinder mượt mà, HybridRAW khởi động thành công, Chụp thường / Chân dung / Master Mode hoạt động không lỗi.
