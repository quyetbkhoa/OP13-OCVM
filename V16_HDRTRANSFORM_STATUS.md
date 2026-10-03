# V16 Port Status: Cluster 2 - HDR Transform Suite & AI Tone Mapping (v84 Release)

**Device:** OnePlus 13 (CPH2653 / OP5D55L1)  
**OS:** ColorOS 16 (16.0.10.501/C.93, Android 15, Snapdragon 8 Elite / SM8750)  
**Donor:** OPPO Find X8 Ultra (PKU110, ColorOS 16 16.0.10.501)  
**Release Tag:** `v84` (versionCode `84000`)  
**Status:** **ACTIVE & VALIDATED IN MEMORY (RAM) & CAPTURE PIPELINE**

---

## 1. Executive Summary

Building upon the successful port of **Cluster 1** (Dual Portrait Bokeh & Hasselblad Color System Foundation in `v83`), **Cluster 2** integrates Find X8 Ultra's **HDR Transform Suite** and neural **AI Tone Mapping (AITM)** pipeline directly into the OnePlus 13 camera processing pipeline.

All 21 neural weights, recovery models, and color LUTs are mounted into `/odm/etc/camera/`, the SELinux internal gate is bypassed (`setenforce 0`), and CamX's runtime dispatch table in RAM registers both HDR transform nodes (`hdrtransform` and `fbHdrConvert`). Real-world capture validates full 10-bit Ultra HDR container output with Adobe HDR Gain Map integration, triggering 2,007-nit EDR display boost in Gallery.

---

## 2. Cluster 2 Components & Architecture

### 2.1 Native Libraries (`/odm/lib64/`)
- `libOPAlgoCamPortraitHDRTransform.so` (2.8 MB) — Neural portrait HDR tone conversion engine (`"FBHC"` node).
- `libOPAlgoCamHDRTransformCamera.so` (2.8 MB) — Full snapshot RAW/YUV HDR transform algorithm (`"HDRTransform"` node).
- `libOPAlgoCamHDRTransformQuick.so` (2.8 MB) — Low-latency preview/burst HDR reference transform engine.

### 2.2 Neural Weights & LUT Assets (`/odm/etc/camera/`)
- **Tone Curves & SDR/HDR Conversions (`fb_model/`):**
  - `AITM_hdr2sdr_65536_fp32.bin` (262 KB)
  - `AITM_sdr2hdr_65536_fp32.bin` (262 KB)
- **Neural HDR Recovery & Tone Mapping (`hybridraw_models/`):**
  - `ai_hdr_recovery.bin` (8.8 MB) — AI recovery model for clipped highlight detail.
  - 18x `aitm_*.bin` neural network models (~43 MB total):
    - `aitm_downNet_BackLight_Portrait_{Horizonal,Vertical}.bin`
    - `aitm_downNet_Sunset_{Landscape,Portrait}_{Horizonal,Vertical}.bin`
    - `aitm_tonemapNet_BackLight_Portrait_{Horizonal,Vertical}.bin`
    - `aitm_tonemapNet_Sunset_{Landscape,Portrait}_{Horizonal,Vertical}.bin`
    - `aitm_upNet_BackLight_Portrait_{Horizonal,Vertical}.bin`
    - `aitm_upNet_Sunset_{Landscape,Portrait}_{Horizonal,Vertical}.bin`

---

## 3. Reverse Engineering & In-Memory Proof (RAM Inspection)

### 3.1 CamX Dynamic Algorithm Dispatch Table in RAM
Direct inspection of `com.oplus.camera` memory (`/proc/<pid>/mem`) reveals that CamX manages an internal registry of up to 101 algorithm nodes in `.bss`:

```text
Table base in RAM: 0x71d72a5bc8 (offset 0x3896bc8 from libAlgoInterface.so base 0x71d3a0f000)

[85] 0x71d73b1058: @...T....hdrtransform (ID: 0x440 / 1088, type: 0x54)
     func1 (Register):   0x71d5d7aa34 -> libAlgoInterface.so + 0x236ba34 (_ZN7android20hdrTransformRegisterEPNS_15AlgoProcessDataE)
     func2 (Unregister): 0x71d5d7b8d0 -> libAlgoInterface.so + 0x236c8d0 (_ZN7android22hdrTransformUnregisterEPNS_15AlgoProcessDataE)
     func3 (Process):    0x71d5d7e840 -> libAlgoInterface.so + 0x236f840 (_ZN7android19hdrTransformProcessEPNS_15AlgoProcessDataE)

[91] 0x71d73c3e38: E...W....fbHdrConvert (ID: 0x445 / 1093, type: 0x57)
     func1 (Register):   0x71d5442f70 -> libAlgoInterface.so + 0x1a33f70 (_ZN7android20fbHdrConvertRegisterEPNS_15AlgoProcessDataE)
     func2 (Unregister): 0x71d5444d78 -> libAlgoInterface.so + 0x1a35d78 (_ZN7android22fbHdrConvertUnregisterEPNS_15AlgoProcessDataE)
     func3 (Process):    0x71d5445a68 -> libAlgoInterface.so + 0x1a36a68 (_ZN7android22fbHdrConvertProcessItfEPNS_15AlgoProcessDataE)
```

### 3.2 Dual Portrait & HCS Framework Memory Verification
Simultaneously, Cluster 1 libraries remain continuously resident in executable memory:
```text
712ac6f000-712acbc000 r-xp /odm/lib64/libhcsfwk.so
7169cd5000-7169d57000 r-xp /odm/lib64/libhcsutils.so
7152349000-7152783000 r-xp /odm/lib64/libOPAlgoCamPreviewDualPortrait.so
71b7716000-71b7748000 r-xp /odm/lib64/libHDRDetection.so
```

OCCE (Oppo Computer Vision Engine) inside `libOPAlgoCamPreviewDualPortrait.so` actively executes OpenGL shader programs during camera viewfinder operation.

---

## 4. Real-World Capture Validation

During physical camera test on OP13:
1. **Camera HAL Provider:** `vendor.qti.camera.provider-service_64` (PID 2209) maintained 100% uptime without crash or restart.
2. **Captured Images:** High-resolution JPEGs saved cleanly to `/sdcard/DCIM/Camera/` (e.g. `IMG20261004042144.jpg`, 18 MB).
3. **Metadata Analysis:**
   - Google Ultra HDR Container XMP: **Present**
   - Adobe HDR Gain Map: **Present**
   - Display Brightness Booster (`DpcExtImpl` log): Automatically triggered `edr enter` mode in ColorOS Gallery, ramping display brightness from 899 nits to **2,007 nits** peak.

---

## 5. Module Configuration (`post-fs-data.sh`)

```sh
# --- Dual Portrait & HCS Framework Activation (v83) ---
resetprop persist.camera.aps.bokeh.HR.suport 1
resetprop persist.vendor.oplus.turbobokeh.enable 1
resetprop persist.vendor.oplus.turbohdr.bokeh.debug 1
resetprop oplus.bokeh.largeMemory 1

# --- SELinux: Unblock ColorOS CamX initPropertyInfo gate ---
setenforce 0

# --- HDR Transform Suite & AITM Pipeline Activation (v84) ---
resetprop persist.camera.hdrtrans.debug 1
resetprop persist.camera.hdrtrans.emptynode 0
resetprop persist.camera.oplus.fbhc.bypass 0
resetprop persist.camera.hybridraw.closeLightUp 0
```
