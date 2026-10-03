# Issue Tracking & Changelog — OP13-OCVM

## V14 Max Safe — verified status

- **Built/offline checked:** separate V14 artifact contains 25 X8U-only libraries and 375 camera data files; ZIP paths, root module files, BOM, and staging/ZIP hashes were verified.
- **Loaded:** X8U-derived BasicTone/LUT data is confirmed by live camera logs (`BasicTone`, `CombineLut`, `SCCWCM`, and `vigTable`).
- **Not loaded:** `libhcsfwk.so`, `libhcsutils.so`, `libomp.so`, DualPortrait, HDRTransform, and VideoLTM libraries were not observed in `com.oplus.camera` or `vendor.qti.camera.provider-service_64` maps.
- **Behavior validated:** rear 1x, front face, Master Mode, and video completed in the captured test window without a new camera/provider crash.
- **Do not claim:** the dormant `.so` libraries are not counted as active X8U algorithm execution.
- **Next investigation:** trace the OP13 caller/registration path and ABI boundary for dormant X8U libraries before adding more activation changes.


## ✅ [RESOLVED in v81] Master Mode Sai màu & Ảnh mất hậu kỳ nét / Chi tiết (Post-processing Bypassed)

**Status:** RESOLVED in v81  
**Nguyên nhân gốc rễ:** 
1. **Sai lệch cân bằng trắng & màu sắc (AWB / Master Mode):** File mod Addon trước đó vô tình chứa `libCS.so` (HAL cảm biến màu quang phổ 13 kênh của Find X8 Ultra thay vì cảm biến 5 kênh TCS3449 của OP13), neural model `AIAWB_q.odnn` của X8U, và các tệp đường cong `gamma_masterMode_quick_hdr_conf.json`. Do OP13 không có cảm biến 13 kênh, HAL đọc sai dữ liệu lux và CCT, ép ISP xuất ma trận màu sai trầm trọng.
2. **Ảnh mờ, thiếu nét, mất bước hậu kỳ (Post-processing Skipped):** 
   - `persist.vendor.camera.edge.skip=1` trong `persist.prop` ra lệnh cho Qualcomm CamX Chi Node bỏ qua toàn bộ bước tái tạo viền sắc nét (edge reconstruction).
   - `vendor.arcsoft.turbo_re_sharpness=0` và `vendor.arcsoft.turbo_hdr_sharpen_*=0` trong `system.prop` ép thuật toán ArcSoft TurboHDR về mức độ nét bằng 0.
   - Thiếu 3 thư viện phụ thuộc thời gian chạy của bộ khung Hasselblad Color System: `libhcsfwk.so`, `libhcsutils.so`, `libomp.so`.
3. **Cơ chế nạp Overlayfs của KernelSU:** KernelSU nạp snapshot overlayfs vào RAM ngay tại thời điểm boot (`post-fs-data`). Mọi thao tác sửa file runtime trong `/data/adb/modules` nếu không reboot máy thì RAM vẫn giữ nguyên các file sai cũ (AIAWB, libCS) của lần boot trước.
**Khắc phục:** 
1. Xóa bỏ triệt để `libCS.so`, `AIAWB_q.odnn`, `*gamma*`, `*golden*`, `*mapxy*`, `*Stereo*` khỏi Addon; để 100% cân bằng trắng ISP và hiệu chuẩn TCS3449 chạy bằng HAL gốc native OP13 C.93.
2. Bổ sung `libhcsfwk.so`, `libhcsutils.so`, `libomp.so` từ 501 vào `odm/lib64/`.
3. Loại bỏ toàn bộ cờ zero-sharpening và `edge.skip=1`, giải phóng toàn bộ khả năng khử nhiễu đa khung, chống mờ và tăng cường chi tiết của ArcSoft RAW TurboHDR và HybridRAW.
4. Hợp nhất trọn vẹn 81 shader `pfb_bin/` và 155 model `fb_model/` giải quyết triệt để lỗi chế độ chân dung làm đẹp khuôn mặt.
5. Tách sạch Main module (chỉ chứa props và service script, không đè `odm/`) và Add-on module (đảm nhiệm toàn bộ thuật toán hậu kỳ).

---

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
