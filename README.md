# TintBeGone™ - by Strung

While direct color removal using shaders such as the Tonemapper may work in removing tint to some extent, I've always found that color subtraction often causes the image to become a too dark, sacrificing clarity. Increasing the source brightness (lower gamma setting) will tend to increase all color values and therefore slowly bring any tint back. This shader is made to bypass that limitation.

TintBeGone™ (not actually trademarked) subtracts the specified color from the image while also bringing each pixel back to its original luminance value after the fact through HSL/RGB conversion. <sub>This part is why prod80's repo is required to make this shader work (for now).</sub>

TintBeGone™ also has a shadow desaturation feature which can be used to desaturate darker areas and gives dark corners and rooms a naturalistic look closer to what you would interpret with your eyes, removing overly saturated shadows. This feature can be disabled depending on the player's preference.

### INSTALLATION
- Install ReShade
- Place the .fx file in <Game .exe directory>\reshade-shaders\Shaders
- Enable the shader in-game

### REQUIREMENTS
- [ReShade](https://reshade.me/) - obviously
- [prod80's shader repo](https://github.com/prod80/prod80-ReShade-Repository) - get the whole repo (available during reshade setup) OR...
- [prod80's PD80_00_Color_Spaces.fxh](https://github.com/prod80/prod80-ReShade-Repository/blob/master/Shaders/PD80_00_Color_Spaces.fxh) - just the color spaces file (place anywhere in reshade-shaders\Shaders)

### HOW TO TUNE
- Stare at something that (regardless of original tint) is supposed to be gray, like a gray concrete wall in a dark alley or a completely dark room.
- Increase tuning boost to allow for fine shadow tuning
- Start removing colors until the resulting picture is grey or has relatively equal distribution between red, green and blue (removing too much can negatively impact results)
- Desaturate shadows according to preference (helps with oversaturated shadows)
- Reset tuning boost
- Enjoy!

### FYI
- The default settings for this shader are my personal tunings to remove the horrendous puke green tint in Cyberpunk 2077 (which is actually more of a vomit yellow). Feel free to adjust the settings to your own liking. It should work in other games with similar color grading, as long as you follow the same tuning steps.
- It should not impact performance. All it does is just some simple color manipulation.
- This thing is by no means a professional piece of code - I am just a hobbyist. 

### FEEDBACK/SUPPORT
- Contact me thru Discord - Strung#8013
- Available on [NexusMods](https://www.nexusmods.com/cyberpunk2077/mods/8118) with images
