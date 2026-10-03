![ocvm](https://i.imgur.com/VoojOSI.png)
# OCVM | OnePlus13 camera mod

**OCVM** is a camera mod that aims at optimizing and boosting all aspects of *OnePlus 13* imaging process. Given that Oppo camera stack provides an immense level of flexibility via whopping amount of comprehensive config interfaces to control many parts of imaging system directly. And with most important parts of the stack - HAL and its subcomponents being almost identical to those of *Oppo find x8 ultra* (*fx8u*). This opens a plethora of possibilities to experiment with and provide an all-rounder full-fledged package.
Mod comes in two packages: 
- A `main module` that is designed to optimize both the stock camera application boosting its quality, as well as third-party cameras (like *gcam*) but with less impact as that would require more low-level patches, that may (or may not) be added in the future. 
- An `addon module` with processing ported from *Oppo find x8 ultra* that affects stock app only.
---

> ### V14 Max Safe validation status
> - V14 device testing confirms X8U-derived BasicTone/LUT data is consumed by the OP13 camera (`BasicTone`, `CombineLut`, `SCCWCM`, and `vigTable` logs).
> - The 25 X8U-only `.so` files are present in the module but were **not observed loaded** in the OP13 camera/provider maps during 1x, front-face, Master Mode, and video tests.
> - Do not describe HCS, DualPortrait, HDRTransform, or VideoLTM as active algorithms until their SONAMEs appear in the camera process maps.
> - Sensor/DSP-risk assets remain excluded: X8U RAW/HybridRAW, QNN/ODNN/CDSP, sensor calibration, EEPROM/DNG/CFR/OIS, and `zf*` hardware configuration.
> - Detailed evidence: [`V14_PORT_STATUS.md`](V14_PORT_STATUS.md).

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