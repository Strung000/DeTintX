# DeTintX - by Strung

Most shaders/presets that aim to remove tint do so by directly subtracting a certain color from the image. This often causes the image to darken, causing shadows to clip and lose shadow clarity. DeTintX aims to work around this limitation by using HSL/RGB conversion to restore each pixel back to its original percieved brightness, in addition to many features that can help fine-tune shadows for more naturalistic color.

### ADDITIONAL FEATURES
- **Shadow Desaturation**: Desaturates darker areas to prevent oversaturated shadows.
- **Levels**: Black and white level adjustment to adjust for deeper blacks and brighter whites.

### INSTALLATION
- Install [ReShade](https://reshade.me/)
- Place the .fx file in <Game .exe directory>\reshade-shaders\Shaders
- Enable the shader in-game

### REQUIREMENTS
- [ReShade](https://reshade.me/)

### FYI
- The default settings for this shader is tuned for removing the green tint in Cyberpunk 2077. Feel free to adjust the settings to your own liking.
- Players using HDR are encouraged to modify the black levels of the image using the sliders to prevent overly bright shadows included in the shader. In my experience, I find that I have to set the black value to around 0.05, but your preference may vary.
- The installation process is the same for all games and ReShade installations.
  
### FEEDBACK/SUPPORT
- Contact me thru Discord - @strung
- Available on [NexusMods](https://www.nexusmods.com/cyberpunk2077/mods/8118) with example screenshots
