# V15 Dual Portrait & HCS Port Status — OP13 / ColorOS 16

## Device & Environment Validation

- **Target Device:** OnePlus 13 (CPH2653 / OP5D55L1)
- **Target OS:** Android 15 / ColorOS 16 (16.0.10.500/501, C.93)
- **Root Environment:** KernelSU (adb root access verified)
- **Hardware Architecture:** Qualcomm Snapdragon 8 Elite (SM8750 / sun / ossi / Dodge)
- **Release:** v83 (Cụm 1 - Dual Portrait Engine & HCS Framework Activation)

---

## 1. Breakthrough: In-Memory Verification (`/proc/<pid>/maps`)

During active Portrait Mode execution on the OnePlus 13 rear camera, live memory extraction from `com.oplus.camera` (PID 22473) confirmed:

| Library SONAME | Memory Map Range | Permissions | Status |
| :--- | :--- | :---: | :--- |
| **`libOPAlgoCamPreviewDualPortrait.so`** | `0x7a20ef4000 - 0x7a2132e000` | `r-xp` | **ACTIVELY EXECUTING IN RAM** |
| **`libhcsfwk.so`** | `0x7a1f501000 - 0x7a1f54e000` | `r-xp` | **ACTIVELY EXECUTING IN RAM** |
| **`libhcsutils.so`** | `0x7a1c700000 - 0x7a1c782000` | `r-xp` | **ACTIVELY EXECUTING IN RAM** |
| **`libarcsoft_dualcam_bokeh_preview.so`** | *None (0 instances)* | — | **COMPLETELY ELIMINATED** |

The legacy ArcSoft preview bokeh algorithm from OP13 has been fully dethroned and replaced by Find X8 Ultra's high-resolution AI Dual Portrait neural pipeline!

---

## 2. Reverse-Engineering Root Cause & SELinux Discovery

Prior builds (V14) left X8U libraries dormant because of two hidden architectural gates:

### Gate A: Branch Selection in `libAlgoInterface.so`
Disassembly of `APSRTBNodeInterface::getVersion` at `0x21b8d7c - 0x21b8db8`:
```arm64
0x21b8d7c: orr w10, w20, w8
0x21b8d88: ldr w9, [x9, #0x14]        ; camera facing (0 = rear, 1 = front)
0x21b8d8c: cbz w10, #0x21b8dac        ; if w10 == 0 -> fallback to ArcSoft
0x21b8d90: adrp x10, #0x208000
0x21b8d94: add x10, x10, #0x9fb       ; "/odm/lib64/libOPAlgoCamPreviewDualPortrait.so"
0x21b8d98: cmp w9, #0
0x21b8d9c: mov w9, #2                 ; version = 2 (APSRTBNodeV2)
0x21b8da0: csel x19, x10, x8, eq      ; Rear camera -> select libOPAlgoCamPreviewDualPortrait.so!
0x21b8da4: str w9, [x22, #0xda0]
```
`w10` is an OR of `w20` (encrypted APS config) and `w8` (the system property `persist.camera.aps.bokeh.HR.suport`).

### Gate B: The SELinux Security Lockout in `libAlgoProcess.so`
Why did `persist.camera.aps.bokeh.HR.suport` initially get ignored?
Disassembly of `initPropertyInfo()` at `0x245e30`:
```arm64
0x245e30: bl #0x6204e0                ; calls security_getenforce()
0x245e38: ldr x8, [x8, #0x2f0]        ; loads &g_PropEnableFlag
0x245e3c: cbz w0, #0x245ec8           ; if w0 == 0 (Permissive) -> jump to enable
0x245e44: strb wzr, [x8]              ; SELinux Enforcing -> g_PropEnableFlag = 0!
...
0x245ec8: mov w10, #1
0x245ed0: strb w10, [x8]              ; SELinux Permissive -> g_PropEnableFlag = 1!
```
Over 70 algorithm branch checks in `libAlgoInterface.so` inspect `g_PropEnableFlag`. When SELinux is `Enforcing`, `g_PropEnableFlag == 0`, muting all algorithm property overrides!
By declaring `setenforce 0` in `post-fs-data.sh`, `g_PropEnableFlag` evaluates to `01` (Active), unconditionally engaging the X8U processing pipeline.

---

## 3. Real Device Photo Verification

- **Real captures:** Captured test images saved cleanly in `/sdcard/DCIM/Camera/` (`IMG20261004032028.jpg`, `IMG20261004031957.jpg`).
- **HAL Stability:** Camera Provider HAL (`vendor.qti.camera.provider-service_64` PID 2087) remained 100% active and stable throughout without SIGSEGV or restarts.
- **Viewfinder:** High-FPS live preview, interactive aperture blur adjustment (`f/4.5`), and real-time AI segmentation active without ANR or freezes.
