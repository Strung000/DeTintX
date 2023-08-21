# DeTintX - by Strung

Most shaders/presets that aim to remove tint do so by directly subtracting a certain color from the image. This often causes the image to darken, causing shadows to clip and lose shadow clarity. DeTintX aims to work around this limitation by using HSL/RGB conversion to restore each pixel back to its original percieved brightness, in addition to many features that can help fine-tune shadows for more naturalistic color.

### FEATURES
- **Shadow Desaturation**: Desaturates darker areas to prevent oversaturated shadows.
- **Shadow Boost**: Boosts the brightness of darker areas to improve visibility.
- **Levels**: Black and white level adjustment to adjust for deeper blacks and brighter whites.

### INSTALLATION
- Install [ReShade](https://reshade.me/)
- Place the .fx file in <Game .exe directory>\reshade-shaders\Shaders
- Enable the shader in-game

### REQUIREMENTS
- [ReShade](https://reshade.me/)

### FYI
- The default settings for this shader is tuned for removing the green tint in Cyberpunk 2077. Feel free to adjust the settings to your own liking.
- The installation process is the same for all games and ReShade installations.
- Pre-2.0 versions of this shader offer a few unintelligent methods for luma preservation that sacrifice color accuracy or percieved luma accuracy. Since 2.0, each pixel is restored back to its percieved luminance using preset luma coefficents. The shader offers a few different choices of luma coefficients (Rec. 709, Rec. 2020, etc.)
- Pre-1.6 versions of this shader require [Color effects by prod80](https://github.com/prod80/prod80-ReShade-Repository) due to needing external HSL/RGB conversion functions to work properly. Since 1.6, proprietary HSL/RGB conversion functions have been implemented, so it is no longer a dependency.
  
### FEEDBACK/SUPPORT
- Contact me thru Discord - @strung
- Available on [NexusMods](https://www.nexusmods.com/cyberpunk2077/mods/8118) with example screenshots
