//DeTintX v1.6.1 - by Strung
//Visit GitHub page for info - https://github.com/Strung000/DetintX

#include "ReShadeUI.fxh"
#include "ReShade.fxh"

//---UI SHIT---

//Detinting
uniform bool detintOn <
    ui_category = "Detinting";
    ui_label = "Detinting";
    ui_tooltip = "Subtract color while preserving brightness.";
> = true;
uniform int preserveLightnessMethod < 
    ui_category = "Detinting";
    ui_label = "Method";
    ui_type = "combo";
    ui_items = "HSL Lightness\0Component Average\0";
    ui_tooltip = "Method of lightness preservation.";
> = 1;
uniform float preserveLightness < __UNIFORM_SLIDER_FLOAT1
    ui_category = "Detinting";
    ui_label = "Preserve Lightness";
    ui_tooltip = "Amount of lightness to preserve.";
> = 1.000;
uniform float detintRed < __UNIFORM_SLIDER_FLOAT1
    ui_category = "Detinting";
    ui_label = "Red";
    ui_tooltip = "Amount of red to remove.";
> = 0.035;
uniform float detintGreen < __UNIFORM_SLIDER_FLOAT1
    ui_category = "Detinting";
    ui_label = "Green";
    ui_tooltip = "Amount of green to remove.";
> = 0.070;
uniform float detintBlue < __UNIFORM_SLIDER_FLOAT1
    ui_category = "Detinting";
    ui_label = "Blue";
    ui_tooltip = "Amount of blue to remove.";
> = 0.000;
uniform float detintMix < __UNIFORM_SLIDER_FLOAT1
    ui_category = "Detinting";
    ui_label = "Mix";
    ui_tooltip = "Amount to blend with input color.";
> = 1.000;

//Shadow Desaturation
uniform bool desaturateShadowsOn <
    ui_category = "Shadow Desaturation";
    ui_label = "Desaturate Dhadows";
    ui_tooltip = "Desaturate darker colors.";
> = true;
uniform float desaturateShadowsStart < __UNIFORM_SLIDER_FLOAT1
    ui_category = "Shadow Desaturation";
    ui_label = "Start";
    ui_tooltip = "Saturation curve start.\n\nColors with lower lightness values than this are fully desaturated.";
> = 0.005;
uniform float desaturateShadowsEnd < __UNIFORM_SLIDER_FLOAT1
    ui_category = "Shadow Desaturation";
    ui_label = "End";
    ui_tooltip = "Saturation curve end.\n\nColors with higher lightness values than this are not desaturated.";
> = 0.150;
uniform float desaturateShadowsMix < __UNIFORM_SLIDER_FLOAT1
    ui_category = "Shadow Desaturation";
    ui_label = "Mix";
    ui_tooltip = "Amount to blend with input color.";
> = 1.000;

//Levels
uniform bool levelsOn <
    ui_category = "Levels";
    ui_label = "Levels";
    ui_tooltip = "Adjust white/black levels.";
> = true;
uniform float blackLevel < __UNIFORM_SLIDER_FLOAT1
    ui_category = "Levels";
    ui_label = "Black Level";
    ui_tooltip = "Adjust black level for deeper blacks.";
> = 0.004;
uniform float whiteLevel < __UNIFORM_SLIDER_FLOAT1
    ui_category = "Levels";
    ui_label = "White Level";
    ui_tooltip = "Adjust white level for brighter highlights.";
> = 0.996;

//Shadow Boost
uniform bool shadowBoostOn <
    ui_category = "Shadow Boost";
    ui_label = "Shadow Boost";
    ui_tooltip = "Boost shadow brightness for improved visibility.";
> = true;
uniform float shadowBoostAmount < __UNIFORM_SLIDER_FLOAT1
    ui_min = 0;
    ui_max = 5;
    ui_category = "Shadow Boost";
    ui_label = "Boost";
    ui_tooltip = "Amount to boost shadow brightness.";
> = 0.250;
uniform float shadowBoostStart < __UNIFORM_SLIDER_FLOAT1
    ui_category = "Shadow Boost";
    ui_label = "Start";
    ui_tooltip = "Shadow boost curve start.\n\nColors with lower lightness values than this are fully boosted.";
> = 0.015;
uniform float shadowBoostEnd < __UNIFORM_SLIDER_FLOAT1
    ui_category = "Shadow Boost";
    ui_label = "End";
    ui_tooltip = "Shadow boost curve end.\n\nColors with higher lightness values than this are not boosted.";
> = 0.250;

//Tuning
uniform bool showClipping <
    ui_category = "Tuning";
    ui_label = "Show Clipping";
    ui_tooltip = "Invert clipped regions.";
> = false;
uniform int tuningBoost < __UNIFORM_SLIDER_FLOAT1
    ui_min = 1;
    ui_max = 10;
    ui_category = "Tuning";
    ui_label = "Boost";
	ui_tooltip = "Boost brightness to fine tune slider values.";
> = 1;

float3 rgb2hsl(float3 rgb)
{
    float r = rgb.r;
    float g = rgb.g;
    float b = rgb.b;

    //Hue
    float h = 0;
    float cMax = max(r, max(g, b));
    float cMin = min(r, min(g, b));
    float c = cMax - cMin;
    if (cMax == r)
    {
        h = (g - b) / (c);
    }
    if (cMax == g)
    {
        h = 2 + ((b - r) / (c));
    }
    if (cMax == b)
    {
        h = 4 + ((r - g) / (c));
    }
    if (h < 0)
    {
        h += 6;
    }

    //Lightness
    float l = 0;
    switch (preserveLightnessMethod)
    {
        case 0:
            l = (cMax + cMin) / 2;
            break;
        case 1:
            l = (r * 0.33f) + (g * 0.33f) + (b * 0.33f);
            break;
    }

    //Saturation
    float s = saturate(c / (1 - abs((2 * l) - 1)));

    return float3(h, s, l);
}

float3 hsl2rgb (float3 hsl)
{
    //HSL
    float h = hsl.x;
    float s = hsl.y;
    float l = hsl.z;

    float c = (1 - abs((2 * l) - 1)) * s;
    float x = c * (1 - abs((h % 2) - 1));
    

    float3 rgb;
    if (h <= 6)
    {
        rgb = float3(c, 0, x);
    }
    if (h <= 5)
    {
        rgb = float3(x, 0, c);
    }
    if (h <= 4)
    {
        rgb = float3(0, x, c);
    }
    if (h <= 3)
    {
        rgb = float3(0, c, x);
    }
    if (h <= 2)
    {
        rgb = float3(x, c, 0);
    }
    if (h <= 1)
    {
        rgb = float3(c, x, 0);
    }

    float m = 0;
    switch (preserveLightnessMethod)
    {
        case 0: //HSL Lightness (Old)
            m = l - (c / 2);
            break;
        case 1: //Component Average
            m = l - ((rgb.x * 0.33f) + (rgb.y * 0.33f) + (rgb.z * 0.33f));
            break;
    }

    rgb += m;

    return rgb;
}

float3 UntintPass(float4 position : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
    //Get Color
    float3 color = tex2D(ReShade::BackBuffer, texcoord).rgb;
    float3 oldHsl = rgb2hsl(color);

    //Detinting
    float3 detintedRgb = color;
    if (detintOn)
    {
        detintedRgb = color - (float3(detintRed, detintGreen, detintBlue) * detintMix);
        detintedRgb = saturate(detintedRgb);
    }
    float3 newHsl = rgb2hsl(detintedRgb);

    //Post-Detinting Lightness Preservation
    float newLightness = (oldHsl.z * preserveLightness) + (newHsl.z * (1 - preserveLightness));

    //Shadow Desaturation
    float newSaturation = newHsl.y;
    if (desaturateShadowsOn)
    {
        if (newHsl.z < desaturateShadowsStart)
        {
            newSaturation = 0;
        }
        else if (newHsl.z > desaturateShadowsEnd)
        {
            //No change
        }
        else
        {
            newSaturation = newHsl.y * saturate(abs((newHsl.z - desaturateShadowsStart) / (desaturateShadowsEnd - desaturateShadowsStart)));
        }

        newSaturation = saturate(newSaturation);
        newSaturation = (newSaturation * desaturateShadowsMix) + (newHsl.y * (1 - desaturateShadowsMix));
    }

    //Levels
    if (levelsOn)
    {
        newLightness = (newLightness - blackLevel) / (whiteLevel - blackLevel);
    }
    
    //Shadow Boost
    if (shadowBoostOn)
    {
        newLightness = saturate(newLightness);

        if (newLightness < shadowBoostStart)
        {
            newLightness *= 1 + shadowBoostAmount;
        }
        else if (newLightness > shadowBoostEnd)
        {
            //No change
        }
        else
        {
            newLightness *= 1 + (shadowBoostAmount * saturate(abs((newLightness - shadowBoostEnd) / (shadowBoostStart - shadowBoostEnd))));
        }
    }

    //Output
    color = float3(newHsl.x, newSaturation, newLightness);
    color = hsl2rgb(color);
    color = saturate(color);

    //Show Clipping
    if (showClipping)
    {
        if ((color.r == 0.0f) && (color.g == 0.0f) && (color.b == 0.0f))
        {
            color = float3(1, 1, 1);
        }
        else if ((color.r == 1.0f) && (color.g == 1.0f) && (color.b == 1.0f))
        {
            color = float3(0, 0, 0);
        }
    }

    //Tuning Boost
    if (tuningBoost > 1)
    {
        color *= tuningBoost;
        color = saturate(color);
    }

    return color;
}

technique DeTintX
{
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader = UntintPass;
	}
}
