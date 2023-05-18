# DeTintX - by Strung

Most shaders/presets that aim to remove tint do so by directly subtracting a certain color from the image. This often causes the image to darken, causing shadows to clip and lose clarity. DeTintX aims to work around this limitation by using HSL/RGB conversion to restore each pixel back to its original brightness. It also sports a few features that can help fine-tune shadows to achieve more naturalistic color.

While it can be used to achieve a stylized look, the true aim of this shader is to respect the intent of the artists and level designers and attempt to restore the original colors as faithfully as possible without as little extra processing as possible.

### FEATURES
- **Shadow Desaturation**: Desaturates darker areas to fix oversaturated shadows and provide a more realistic look to darker areas.
- **Shadow Boost**: Boosts the brightness of darker areas to improve visibility at the cost of shadow contrast.
- **Levels**: Black and white level adjustment to adjust for deeper blacks and brighter whites.

### INSTALLATION
- Install [ReShade](https://reshade.me/)
- Place the .fx file in <Game .exe directory>\reshade-shaders\Shaders
- Enable the shader in-game

### REQUIREMENTS
- [ReShade](https://reshade.me/)

### FYI
- The default settings for this shader are my personal tunings to remove the horrendous puke green tint in Cyberpunk 2077 (which is actually more of a vomit yellow). Feel free to adjust the settings to your own liking. It should work in other games with similar color grading.
- There are 2 ways the shader can calculate what brightness to restore a certain pixel back to. "HSL Lightness" is the old pre-1.6 method, which works well in midtones and highlights but suffers from bad gradients and inaccurate shadows, causing more relatively bright colors like yellow to appear much darker when in shadow, sacrificing clarity. "Component Average" is a different method that is slightly less accurate but has good gradients and better color representation in the shadows. I prefer the look of Component Average, but if you notice any particularly bad color artifacts with this method, let me know and I can try to implement other methods.
- Pre-1.6 versions of this shader require [Color effects by prod80](https://github.com/prod80/prod80-ReShade-Repository) due to needing external HSL/RGB conversion functions to work properly. Since 1.6, I have implemented my own HSL/RGB conversion functions, so this is no longer a dependency.
  
### FEEDBACK/SUPPORT
- Contact me thru Discord - Strung#8013
- Available on [NexusMods](https://www.nexusmods.com/cyberpunk2077/mods/8118) with example screenshots
