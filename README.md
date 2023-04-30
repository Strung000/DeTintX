# DeTintX - by Strung

While direct color removal using shaders such as ReShade's Tonemapper may work in removing tint to some extent, color subtraction often causes the image to become darker and clip, sacrificing clarity in the shadows. Increasing the source brightness will tend to increase all color values and therefore slowly bring any tint back. This shader is made to work around that limitation by allowing the user to carefully fine-tune shadows for a naturalistic appearance.

The aim of this shader is to respect the intent of the visual artists and level designers while attempting to reproduce the original unaltered colors. No more, no less. Grays actually look gray, blues look blue, reds look red, and greens look green.

DeTintX subtracts the specified color from the image while also bringing each pixel back to its original luminance value after the fact through HSL/RGB conversion. <sub>This part is why prod80's shader package is required to make this work (for now).</sub>

DeTintX also has a shadow desaturation feature which can be used to desaturate darker areas and gives dark corners and rooms a more realistic appearance by removing overly saturated shadows. This feature can be disabled depending on the player's preference.

### INSTALLATION
- Install [ReShade](https://reshade.me/)
- Make sure ["Color effects by prod80"](https://github.com/prod80/prod80-ReShade-Repository) is ticked during package selection
- Place the .fx file in <Game .exe directory>\reshade-shaders\Shaders
- Enable the shader in-game

### REQUIREMENTS
- [ReShade](https://reshade.me/) - obviously
- [Color effects by prod80](https://github.com/prod80/prod80-ReShade-Repository) - get the whole shader package (available during reshade setup) OR...
- [PD80_00_Color_Spaces.fxh](https://github.com/prod80/prod80-ReShade-Repository/blob/master/Shaders/PD80_00_Color_Spaces.fxh) - just the color spaces file (place anywhere in reshade-shaders\Shaders)

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

### FEEDBACK/SUPPORT
- Contact me thru Discord - Strung#8013
- Available on [NexusMods](https://www.nexusmods.com/cyberpunk2077/mods/8118) with images
