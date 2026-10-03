![ocvm](https://i.imgur.com/VoojOSI.png)
# OCVM | OnePlus13 camera mod

**OCVM** is a camera mod that aims at optimizing and boosting all aspects of *OnePlus 13* imaging process. Given that Oppo camera stack provides an immense level of flexibility via whopping amount of comprehensive config interfaces to control many parts of imaging system directly. And with most important parts of the stack - HAL and its subcomponents being almost identical to those of *Oppo find x8 ultra* (*fx8u*). This opens a plethora of possibilities to experiment with and provide an all-rounder full-fledged package.
Mod comes in two packages: 
- A `main module` that is designed to optimize both the stock camera application boosting its quality, as well as third-party cameras (like *gcam*) but with less impact as that would require more low-level patches, that may (or may not) be added in the future. 
- An `addon module` with processing ported from *Oppo find x8 ultra* that affects stock app only.
---

> ### 🎯 V16 HDR Transform & AI Tone Mapping Validation Status
> - **In-Memory Verification Confirmed**: Memory inspection of `com.oplus.camera` algorithm table in RAM (`/proc/<pid>/mem`) confirms both Node 85 (`hdrtransform`) and Node 91 (`fbHdrConvert`) are registered into the CamX runtime execution graph.
> - **Full Neural Weights & LUT Assets Mounted**: Deployed 21 neural network models and tone LUTs (2x `AITM_*` in `fb_model/`, `ai_hdr_recovery.bin`, and 18x `aitm_*.bin` in `hybridraw_models/`, ~52MB).
> - **10-bit Ultra HDR & Adobe Gain Map Integration**: Captured images output full Google Ultra HDR Container XMP and Adobe HDR Gain Map metadata, activating 2,007-nit peak EDR display boost in ColorOS Gallery.
> - **Dual Portrait & HCS Framework Still Live**: `libOPAlgoCamPreviewDualPortrait.so`, `libhcsfwk.so`, and `libhcsutils.so` remain resident and active in RAM (`r-xp`).
> - Detailed evidence & disassembly: [`V16_HDRTRANSFORM_STATUS.md`](V16_HDRTRANSFORM_STATUS.md).

---

> ### 🚀 Release v85 (Find X8 Ultra Video LTM & Video AI Process Unlocked)
> - **Video LTM & Video AI Process Active**: Deployed Find X8 Ultra's CamX Chi node components (`com.oplus.node.videoltm.so`, `com.oplus.node.videoainr.so`) and processing engines (`libVideoLTM.so`, `libVideoAIProc.so`).
> - **CamX Hardware Config Integration**: Appended native `[VideoLTMNode]` section to `CameraHWConfiguration.config` and deployed missing `video_ai_proc_cfg.json` without breaking base OP13 sensor pipelines.
> - **V15 Crash Root Cause Resolved**: Fixed the missing Chi node wrappers and incomplete node configuration table that previously caused NullPointerException on camera initialization.
> - **Runtime Verified**: Live camera preview and video capture validated with zero crashes under ColorOS 16 (16.0.10.501/C.93).
> - **Tuning Properties Active**: `persist.camera.videoltm.enable=1`, `vendor.oplus.camera.vLTMTurnOff=0`, `vendor.oplus.camera.vAINRTurnOff=0`, `vendor.oplus.camera.vAINRAlgoTurnOff=0`.

---

> ### 🚀 Release v84 (Find X8 Ultra HDR Transform Suite & AI Tone Mapping)
> - **Find X8 Ultra HDR Transform Pipeline Active**: Integrated `libOPAlgoCamPortraitHDRTransform.so`, `libOPAlgoCamHDRTransformCamera.so`, and `libOPAlgoCamHDRTransformQuick.so` into the processing stack.
> - **AI Tone Mapping Neural Weights & Recovery**: Mounted 18 `aitm_*.bin` neural nets, `ai_hdr_recovery.bin`, and AITM 65536 fp32 SDR/HDR LUT curves.
> - **Ultra HDR & EDR Boost**: Verified Google Ultra HDR container formatting and real-time display EDR animation up to 2,007 nits.
> - **Dual Portrait Engine & HCS Uncompromised**: Preserves full HCS framework and 45-model dual-cam portrait bokeh engine in memory.

---

> ### 🚀 Release v83 (Find X8 Ultra Dual Portrait & HCS Engine Live)
> - **Find X8 Ultra Dual Portrait Engine Active**: Successfully deployed and validated the 45 AI models & neural network shaders under `/odm/etc/camera/dualcam_capture_bokeh/`.
> - **Hasselblad Color System (HCS) Active**: Full runtime integration of `libhcsfwk.so` and `libhcsutils.so` running directly inside `com.oplus.camera`.
> - **Dynamic Algorithm Gate Unlocked**: Overcame the SELinux Enforcing block in `libAlgoProcess.so`, ensuring persistent activation of all advanced Oppo CamX algorithm properties.
> - **Rock-Solid Hardware Stability**: 100% preservation of OP13 sensor mappings (`dodgemain`, `dodge*`) and native buffer pool configurations. No HAL SIGSEGV crashes.

---

> ### 🚀 Release v81 (ColorOS 16 / C.93 / 501 Full Support)
> - **Color Accuracy & AWB Restored**: Purged incompatible Find X8 Ultra 13-channel spectral sensor HAL (`libCS.so`), X8U AI White Balance neural model (`AIAWB_q.odnn`), golden spectral calibration, and X8U gamma curve overrides. Master Mode, Photo Mode, and Night Mode now run with 100% native OnePlus 13 TCS3449 color sensor calibration and ISP white balance.
> - **Full Computational Post-Processing & Sharpness**: Integrated missing Hasselblad Color System framework dependencies (`libhcsfwk.so`, `libhcsutils.so`, `libomp.so`). Removed artificial zero-sharpening overrides (`vendor.arcsoft.turbo_*_sharpness=0`) and Qualcomm CamX `edge.skip=1`, allowing ArcSoft TurboHDR and CamX to execute full multi-frame deblurring, detail synthesis, and crisp edge reconstruction.
> - **Portrait Mode & Face Retouch Fix**: Merged full suite of 81 native OP13 C.93 face retouch shaders (`pfb_bin/`) and 155 makeup neural models (`fb_model/`), eliminating portrait segmentation and beauty processing glitches.
> - **Clean Architecture Decoupling**: Completely segregated Main module (system/persist props, CamX bandwidth/clock tuning, and service daemon) from Add-on module (pure computational photography engine: ArcSoft TurboHDR 147MB, HybridRAW 13.7MB, Dual Portrait 18.2MB, Hasselblad LUTs), eliminating overlayfs collisions.

---


> ## :one: Main module
> Aims at general optimization with image quality being major priority. Fights atrocious levels of sharpening & denoise, corrects various oplus mistakes/overlooks, disables what shouldn't be, enables what should, adds & reworks what can be reused from *fx8u*.
>
>> - ### **Features:**
>> - #### **Blobs**
>>   + disabled jpeg compression
>>   + HAL noise reduction api2 key skip
>>   + boosted thdr deconvolution
>> + #### **Sensor**
>>   + custom noise models for main & front lenses
>>   + disabled anr/ipe/demosaic denoise for main & tele lenses (**by savitar**)
>> + #### **Vendor interfaces**
>>   + upstreamed, corrected & reworked HAL config
>>   + upstreamed & reworked mode config
>>   + upstreamed & reworked aux switch config
>>   + upstreamed & reworked hr config
>>   + upstreamed & reworked ois/eis configs
>>   + edited per-sensor configs
>>     + upstreamed keys/values from *fx8u*
>>     + corrected lux parameters
>>     + disabled denoising/sharpening
>>   + edited various sw<->hw configs
>>     + added various internal keys
>>     + optimized various keys values
>>     + enabled various hidden cam app features
>
>> - ### **Known bugs:**
>>   - #### uwide to main camera switching in photo modes hangs camera
>>   - #### laggy portrait mode preview
>
>
> :exclamation: **Module clears stock camera app data** :exclamation:
>
> **you will need to set camera app again after module installation**
>

> ## :two: Addon module
> Ported *fx8u* imaging blobs. Corrects their work (to possible extend) on *op13*, restores microdetails & textures rendition in hdr mode.
>
>> - ### **Features:**
>> - #### **Blobs**
>>   + upstreamed & corrected various blobs from *fx8u*
>>   + maximum precision 32bit floating point tonemapping
>>   + forced FP32 processing
>>   + boosted malloc (experimental)
>>   + corrected & reworked JDD kernel
>
>> - ### **Known bugs:**
>>   - #### merge "bleed" in scenes where sun hits camera at an angle
>>   - #### zoom levels above 10x don't save final image
>

> ## :warning: Installation and requirements
> + OOS16 OnePlus13
>   + COS users can test & report back if mod works there
> + Supported root methods: Magisk/KernelSU/KernelSU Next/APatch

> ## :incoming_envelope: Support
> + [UCVM/OCVM telegram group](https://t.me/ucvm_gcam/24733)