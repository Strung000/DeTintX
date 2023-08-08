# DeTintX - by Strung

Most shaders/presets that aim to remove tint do so by directly subtracting a certain color from the image. This often causes the image to darken, causing shadows to clip and lose shadow clarity. DeTintX aims to work around this limitation by using HSL/RGB conversion to restore each pixel back to its original brightness, in addition to many features that can help fine-tune shadows for more naturalistic color.

The aim of this shader is to respect the intent of the artists and level designers by undoing excessive or bad color correction. Intended to be used as subtly as possible.

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
- There are 2 ways the shader can calculate what brightness to restore a certain pixel back to. "HSL Lightness" is the old method, which works well in midtones and highlights but suffers from bad gradients and inaccurate shadows, causing hues that are percieved as "brighter" like yellow to appear much darker when in shadow. "Component Average" is a different method that is slightly less color-accurate but has good gradients and better shadows.
- Pre-1.6 versions of this shader require [Color effects by prod80](https://github.com/prod80/prod80-ReShade-Repository) due to needing external HSL/RGB conversion functions to work properly. Since 1.6, proprietary HSL/RGB conversion functions have been implemented, so it is no longer a dependency.
  
### FEEDBACK/SUPPORT
- Contact me thru Discord - @strung
- Available on [NexusMods](https://www.nexusmods.com/cyberpunk2077/mods/8118) with example screenshots
