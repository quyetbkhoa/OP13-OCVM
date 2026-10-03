# OP13 Camera Port — Next Agent Handoff (V15)

Date: 2026-10-03

## Scope

This document is the current handoff for continuing the Find X8 Ultra image-processing port to the OnePlus 13. It records the verified V14 baseline, the V15 VideoLTM experiment, the failure and rollback, and the next safe investigation path.

## Device and environment

- Target: OnePlus 13 CPH2653 / OP5D55L1
- ROM: ColorOS 16, `CPH2653_16.0.10.500(EX01)` / C.93 / 501
- Root: KernelSU
- Slot: `_a`
- ADB: `C:\Apps\platform-tools\adb.exe`
- Serial observed: `223af0b7`
- Device was verified in state `device` during this session.
- Project: `W:\Tools\OP13CamMod`
- Repo: `W:\Tools\OP13CamMod\quyetbkhoa-OP13-OCVM`
- Remote: `https://github.com/quyetbkhoa/OP13-OCVM.git`

Always run `adb devices -l` before device conclusions. Only `device` is acceptable; do not treat `offline` or `unauthorized` as ready.

## Git baseline before this handoff

- HEAD/local main: `85fba63` (`v82`)
- `origin/main`: `85fba634de2f0c74ec4e65a379544e50c1cad8b4`
- Remote tag `v82`: `b44d31619ba347c683f3b6f8ad3daa7650f79111`
- Working tree was clean before this handoff document.

## V14 status after rollback

V14 is the active and verified-safe module after the V15 rollback:

```text
id=op13_x8u_camera_port
version=v14.0
versionCode=14
```

The active KernelSU module path is:

```text
/data/adb/modules/op13_x8u_camera_port
```

The V15 installation created a temporary backup at:

```text
/data/adb/modules/op13_x8u_camera_port_v14_backup
```

That backup was used to restore V14, and the device was rebooted. Post-rollback checks showed:

- camera provider: `running`
- `cameraserver`: running
- `libAlgoInterface.so` and `libAlgoProcess.so` present in cameraserver maps
- no claim that dormant V14 X8U libraries are loaded

## Known-good V14 facts

### Built / offline checked

The V14 artifact is:

```text
W:\Tools\OP13CamMod\OP13-X8U-Hasselblad-Pipeline.zip
```

Previously verified:

- 403 ZIP entries
- 25 X8U-only `.so` files
- 375 camera data files
- root-level `module.prop`
- no backslashes in ZIP entries
- no staging-directory prefix
- `module.prop` without BOM
- staging and ZIP contents match by SHA-256

### Loaded and behavior validated

X8U-derived BasicTone/LUT data is actually consumed by the OP13 camera. Confirmed log strings include:

- `BasicTone VERSION(QCOM): 2024-07-29 23-00`
- `Using_LMTPath: /odm/etc/camera/basictone/lmt`
- `Using_ODTPath: /odm/etc/camera/basictone/odt`
- `Using_VigPath: /odm/etc/camera/basictone/vig`
- `Using_SetPath: /odm/etc/camera/basictone/setting`
- `CombineLut... SimTool_Setting: /odm/etc/camera/basictone/setting/SimTool_Master.ini`
- `CombineLut... Only SC CWCM`
- `BasicToneRender::SCCWCM`
- `BasicToneRender::vigTable`
- `BasicTone processImage`

The captured V14 test window completed:

- rear 1x
- front face capture
- Master Mode capture
- video recording

No new camera/provider `CANNOT LINK`, fatal signal, or SIGSEGV was observed in that V14 test window.

### Not loaded / unverified

These were mounted under `/odm` but were not observed in `com.oplus.camera` or `vendor.qti.camera.provider-service_64` maps:

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

Presence under `/data/adb/modules` or `/odm` is not proof of execution.

## V15 VideoLTM experiment

### Artifact

The isolated V15 probe was built at:

```text
W:\Tools\OP13CamMod\OP13-X8U-Hasselblad-Pipeline-v15-videoltm.zip
```

SHA-256:

```text
6042a81c6ff67b9a1086ceb88059dff08fe5d094a30664b91954bd81624abb91
```

Offline checks passed:

- 404 ZIP entries
- 25 `.so` files
- 376 camera data files
- forward-slash ZIP paths
- root-level `module.prop`
- staging/ZIP byte-hash verification

Only these three X8U camera data files were added over the V14 staging payload:

```text
odm/etc/camera/video_ltm.json
odm/etc/camera/video_ltm_ctrl.json
odm/etc/camera/config/video_ai_proc_cfg.json
```

The V15 attempt did **not** replace `CameraHWConfiguration.config`, did not replace the caller libraries, and did not add QNN/ODNN/CDSP/DSP or sensor-specific assets.

### Device result

V15 was staged, rebooted, and then checked. The files appeared under `/odm` and the module reported:

```text
version=v15.0-videoltm
versionCode=15
```

However, the Camera app repeatedly crashed with Java `NullPointerException`:

```text
Unable to start activity ComponentInfo{com.oplus.camera/com.oplus.camera.Camera}
java.lang.NullPointerException
Objects.java:504
```

and:

```text
Attempt to invoke virtual method
'void com.oplus.ocs.camera.CameraUnitClient.openCamera(...)'
on a null object reference
OneCameraImpl.java:84
```

The provider remained running, but there was no evidence that any intended V15 algorithm loaded:

- no `libVideoLTM.so` in maps
- no `libVideoAIProc.so` in maps
- no DualPortrait/HDRTransform/HCS library in maps
- no corresponding VideoLTM registration/process log

Conclusion:

- V15 VideoLTM data probe: **Failed / Rolled back**
- It is not valid to claim VideoLTM was activated.
- Adding only the three config/data files is insufficient and causes a Camera app initialization regression on this device state.

## Offline caller analysis

`libAlgoInterface.so` is byte-identical between extracted OP13 and X8U:

```text
size: 59,379,736 bytes
sha256: 548da124a432010a464ce6b14b5ce23cfd219dff186e1c81a6ea76ee7932c156
```

`libAlgoProcess.so` is also byte-identical:

```text
size: 6,588,720 bytes
sha256: 2703cca48249c5a30648c8a018981b6a9b09da5e2474ff4fc412ae509ec94eda
```

`libAlgoInterface.so` contains strings and code references for:

- `libOPAlgoCamPreviewDualPortrait.so`
- `libOPAlgoCamCaptureDualPortrait.so`
- `libOPAlgoCamPortraitHDRTransform.so`
- `libOPAlgoCamHDRTransformCamera.so`
- `libOPAlgoCamHDRTransformQuick.so`
- `libOPAlgoCamSegment.so`
- `dlopen`
- `android_dlopen_ext`
- `dlsym`
- HDRTransform registration/process
- portrait/segment registration
- `com.oplus.aps.params.preview.dlopenturbohdr`

This proves dormant-capable code exists in the shared caller. It does not prove that the required feature/mode/config path is reached.

Selected V14 dependencies:

- PreviewDualPortrait → `libhcsfwk.so`, `libhcsutils.so`, `libzlib.so`, `libsharebuffer.so`, `libtrace.so`, graphics/system libs
- HCS framework → `libhcsutils.so`, `libc++_shared.so`, system libs
- CaptureDualPortrait → `libOPAlgoCamSegment.so`, `libsharebuffer.so`, `libtrace.so`, system libs
- Segment → `libODNN.so`, system libs
- VideoLTM → `libtrace.so`, graphics/system libs

On the device, the direct files are available under `/odm/lib64` or `/vendor/lib64`, so simple file absence is not the complete explanation for dormancy.

## Important safety exclusions

Do not blindly port or re-enable:

- X8U `libarcsoft_turbo_hdr_raw.so`
- X8U `libOPAlgoCamHybridRaw.so`
- X8U `hybridraw_models/`
- X8U QNN/ODNN/CDSP/DSP assets
- X8U sensor calibration, EEPROM, DNG, CFR, OIS, or `zf*` configuration
- system/modem/radio/commcenter libraries

Previous tests associated these with black frames, blur, front-camera failure, provider crashes, or bootloop.

Do not replace `libAlgoInterface.so` or `libAlgoProcess.so`; the extracted OP13 and X8U copies are identical.

Do not re-enable V14 Master Mode `LMT`, `ODT`, or `Merge` transforms until HCS is objectively loaded and the mode is behavior-validated.

## Recommended next work

1. Treat V14 as the known-good baseline.
2. Do not retry the V15 three-file VideoLTM data-only probe.
3. Offline-diff X8U and OP13 `CameraHWConfiguration.config` by section, not whole-file replacement. The X8U file contains `[VideoLTMNode]` and other hardware/mode configuration; the OP13 file is shorter and sensor-target-specific.
4. Locate the exact OP13-native config path and registration gate for VideoLTM before modifying anything.
5. Search live camera logs during an unmodified V14 video session for the native VideoLTM caller, operation mode, and config lookup.
6. If a new experiment is justified, build one versioned module with a complete rollback backup and test only one functional group.
7. After every change, verify:
   - `adb devices -l`
   - boot completion/provider/cameraserver state
   - `/proc/<pid>/maps`
   - linker/SELinux/provider logs
   - camera app launch
   - rear 1x, front face, Master Mode, HDR/portrait, and video
8. Use the required labels exactly: **Built**, **Offline checked**, **Loaded**, **Behavior validated**, **Unverified**.

## Useful project files

- `HISTORY.md`
- `build_v14.ps1`
- `make_zip_v14.py`
- `monitor_v14/`
- `V14_PORT_STATUS.md`
- `V15_ACTIVATION_ANALYSIS.md`
- `build_v14.ps1` currently documents the V14 allowlist and deliberate exclusions.

## Current conclusion

V14 is the last known-good baseline. BasicTone/LUT data is **Loaded** and **Behavior validated**. The dormant X8U `.so` group is only **Built**, mounted, and **Unverified**. The V15 VideoLTM data-only activation experiment caused a reproducible Camera app Java initialization failure without loading VideoLTM; it was rolled back. The next agent must investigate the native caller/config gate offline and avoid another blind configuration injection.
