# V14 X8U Port Status — OP13 / ColorOS 16

## Device validation

- Device: OnePlus 13 CPH2653 / OP5D55L1
- ROM: `CPH2653_16.0.10.500(EX01)`
- Root: KernelSU
- Slot: `_a`
- Active module: `op13_x8u_camera_port` v14.0
- ADB: authorized and root shell confirmed

## Artifact checks

The V14 staging build and ZIP were checked offline:

- 25 X8U-only `.so` files in `odm/lib64`
- 375 camera data files in `odm/etc/camera`
- 403 ZIP entries
- Root-level `module.prop`, `post-fs-data.sh`, and `service.sh`
- Zero backslash ZIP entries
- Zero staging-directory prefixes
- Staging files and ZIP entries match by SHA-256
- `module.prop` is ASCII without BOM

## Confirmed working on the device

### X8U-derived data pipeline

The camera log shows the following live paths and processing calls:

- `/odm/etc/camera/basictone/lmt`
- `/odm/etc/camera/basictone/odt`
- `/odm/etc/camera/basictone/vig`
- `/odm/etc/camera/basictone/setting/SimTool_Master.ini`
- `BasicTone VERSION(QCOM): 2024-07-29 23-00`
- `BasicToneRender::SCCWCM`
- `BasicToneRender::vigTable`
- `BasicTone processImage`
- `CombineLut... Only SC CWCM`

Therefore the X8U-derived BasicTone/LUT data is actively consumed by the OP13 camera pipeline.

### Camera behavior

During device testing, these flows completed without a new camera/provider crash:

- Rear 1x capture
- Front face capture
- Master Mode capture
- Video recording

No new `CANNOT LINK`, `Fatal signal`, or `SIGSEGV` was observed in the captured test window.

## Not confirmed / not working as an X8U algorithm port

The following libraries are present in the module and live under `/odm`, but were **not observed in the maps of** `com.oplus.camera` or `vendor.qti.camera.provider-service_64`:

- `libhcsfwk.so`
- `libhcsutils.so`
- `libomp.so`
- `libOPAlgoCamPreviewDualPortrait.so`
- `libOPAlgoCamCaptureDualPortrait.so`
- `libOPAlgoCamPortraitHDRTransform.so`
- `libOPAlgoCamHDRTransformCamera.so`
- `libOPAlgoCamHDRTransformQuick.so`
- `libVideoLTM.so`
- `libVideoAIProc.so`

They are **available**, but not proven loaded or executed. Presence in the module filesystem is not counted as a successful algorithm port.

## Deliberate exclusions

These remain excluded from V14 because earlier device tests showed black frames, blur, front-camera failure, crash, or bootloop:

- X8U `libarcsoft_turbo_hdr_raw.so`
- X8U `libOPAlgoCamHybridRaw.so`
- X8U `hybridraw_models/`
- X8U QNN/ODNN/CDSP/DSP assets
- X8U sensor calibration, EEPROM, DNG, CFR, OIS, and `zf*` hardware configuration
- System/modem/radio/commcenter libraries

## Required next engineering step

To activate the dormant X8U `.so` group, trace the OP13 caller/registration path and ABI boundary. Do not claim HCS, DualPortrait, HDRTransform, or VideoLTM execution until the expected SONAMEs appear in the actual camera process maps during the corresponding mode.

## Status labels

- **Built:** V14 ZIP generated.
- **Offline checked:** archive, path, BOM, count, and hash checks passed.
- **Loaded:** BasicTone/LUT data confirmed in live logs; listed X8U `.so` libraries are not loaded.
- **Behavior validated:** listed camera modes completed without new crash in the captured test window.
- **Unverified:** actual use of dormant X8U `.so` algorithm libraries.
