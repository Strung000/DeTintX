//DetintX v1.5 - by Strung

#include "ReShadeUI.fxh"
#include "ReShade.fxh"
#include "PD80_00_Color_Spaces.fxh" //this file from the prod80 repo is REQUIRED - get the whole prod80 shader repo (or just this file) to make this work

//---UI SHIT---

uniform bool detintOn <
    ui_category = "Detinting";
    ui_label = "Detinting";
    ui_tooltip = "Subtract color while preserving brightness.";
> = true;
uniform float preserveLuminance < __UNIFORM_SLIDER_FLOAT1
    ui_category = "Detinting";
    ui_label = "Preserve Luminance";
    ui_tooltip = "Amount of luminance to preserve.\n\nNo preservation will directly subtract color.";
> = 1.000;
uniform float detintRed < __UNIFORM_SLIDER_FLOAT1
    ui_category = "Detinting";
    ui_label = "Red";
    ui_tooltip = "Amount of red to remove.";
> = 0.055;
uniform float detintGreen < __UNIFORM_SLIDER_FLOAT1
    ui_category = "Detinting";
    ui_label = "Green";
    ui_tooltip = "Amount of green to remove.";
> = 0.075;
uniform float detintBlue < __UNIFORM_SLIDER_FLOAT1
    ui_category = "Detinting";
    ui_label = "Blue";
    ui_tooltip = "Amount of blue to remove.";
> = 0.010;
uniform float detintMix < __UNIFORM_SLIDER_FLOAT1
    ui_category = "Detinting";
    ui_label = "Mix";
    ui_tooltip = "Fade between full effect application and none.\n\nUse lower values with proportionally high color values for finer tuning\n(e.g. rgb(0.01,0.02,0,03) @ 100% mix = rgb(0.10,0.20,0.30) @ 10% mix";
> = 1.000;

uniform bool desaturateShadowsOn <
    ui_category = "Shadow Desaturation";
    ui_label = "Desaturate Dhadows";
    ui_tooltip = "Desaturate darker areas for a more natural appearance.";
> = true;
uniform float desaturateShadowsStart < __UNIFORM_SLIDER_FLOAT1
    ui_category = "Shadow Desaturation";
    ui_label = "Start";
    ui_tooltip = "Saturation curve start.\n\nColors with lower luminance values than this are fully desaturated.";
> = 0.010;
uniform float desaturateShadowsEnd < __UNIFORM_SLIDER_FLOAT1
    ui_category = "Shadow Desaturation";
    ui_label = "End";
    ui_tooltip = "Saturation curve end.\n\nColors with higher luminance values than this are not desaturated.";
> = 0.250;
uniform float desaturateShadowsLinearity < __UNIFORM_SLIDER_FLOAT1
    ui_category = "Shadow Desaturation";
    ui_label = "Linearity";
    ui_tooltip = "Saturation curve linearity.\n\nAffects the curvature of the saturation function. Higher values are more linear.";
> = 0.500;
uniform float desaturateShadowsMix < __UNIFORM_SLIDER_FLOAT1
    ui_category = "Shadow Desaturation";
    ui_label = "Mix";
    ui_tooltip = "Fade between full effect application and none.";
> = 0.900;

uniform bool levelsOn <
    ui_category = "Levels";
    ui_label = "Levels";
    ui_tooltip = "Adjust white/black levels.";
> = true;
uniform float blackLevel < __UNIFORM_SLIDER_FLOAT1
    ui_category = "Levels";
    ui_label = "Black Level";
    ui_tooltip = "Adjust black level for deeper blacks.";
> = 0.002;
uniform float whiteLevel < __UNIFORM_SLIDER_FLOAT1
    ui_category = "Levels";
    ui_label = "White Level";
    ui_tooltip = "Adjust white level for brighter highlights.";
> = 1.000;

uniform bool shadowBoostOn <
    ui_category = "Shadow Boost";
    ui_label = "Shadow Boost";
    ui_tooltip = "Boost shadow brightness for improved visibility in darker areas.\n\nWILL sacrifice contrast - increasing source brightness and retuning is recommended instead.";
> = true;
uniform float shadowBoostAmount < __UNIFORM_SLIDER_FLOAT1
    ui_min = 0;
    ui_max = 5;
    ui_category = "Shadow Boost";
    ui_label = "Boost";
    ui_tooltip = "Amount to boost shadow brightness.";
> = 0.600;
uniform float shadowBoostStart < __UNIFORM_SLIDER_FLOAT1
    ui_category = "Shadow Boost";
    ui_label = "Start";
    ui_tooltip = "Shadow boost curve start.\n\nColors with lower luminance values than this are fully boosted.";
> = 0.015;
uniform float shadowBoostEnd < __UNIFORM_SLIDER_FLOAT1
    ui_category = "Shadow Boost";
    ui_label = "End";
    ui_tooltip = "Shadow boost curve end.\n\nColors with higher luminance values than this are not boosted.";
> = 0.600;
uniform float shadowBoostLinearity < __UNIFORM_SLIDER_FLOAT1
    ui_category = "Shadow Boost";
    ui_label = "Linearity";
    ui_tooltip = "Shadow boost curve linearity.\n\nAffects the curvature of the boost function. Higher values are more linear.";
> = 0.150;

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
	ui_tooltip = "Boost brightness to fine tune shadows.\n\nSee documentation for tuning guide.";
> = 1;


//---THE ACTUAL SHIT---

float3 UntintPass(float4 position : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
    float3 color = tex2D(ReShade::BackBuffer, texcoord).rgb;
    float3 oldHsl = RGBToHSL(color);

    //Detinting
    float3 detintedRgb = color;
    if (detintOn)
    {
        float3 detintColor = float3(detintRed, detintGreen, detintBlue);
        detintedRgb = color - (detintColor * detintMix);
        detintedRgb = saturate(detintedRgb);
    }

    float3 newHsl = RGBToHSL(detintedRgb);

    //Post-Detinting Luminance Preservation
    float newLuminance = (oldHsl.z * preserveLuminance) + (newHsl.z * (1 - preserveLuminance));

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
            newSaturation = newHsl.y * saturate(pow(abs((newHsl.z - desaturateShadowsStart) / (desaturateShadowsEnd - desaturateShadowsStart)), desaturateShadowsLinearity));
        }

        newSaturation = saturate(newSaturation);
        newSaturation = (newSaturation * desaturateShadowsMix) + (newHsl.y * (1 - desaturateShadowsMix));
    }

    //Levels
    if (levelsOn)
    {
        newLuminance = (newLuminance - blackLevel) / (whiteLevel - blackLevel);
    }
    
    //Shadow Boost
    if (shadowBoostOn)
    {
        
        newLuminance = saturate(newLuminance);

        if (newLuminance < shadowBoostStart)
        {
            newLuminance *= 1 + shadowBoostAmount;
        }
        else if (newLuminance > shadowBoostEnd)
        {
            //No change
        }
        else
        {
            newLuminance *= 1 + (shadowBoostAmount * saturate(pow(abs((newLuminance - shadowBoostEnd) / (shadowBoostStart - shadowBoostEnd)), 1 / shadowBoostLinearity)));
        }
    }

    //Output
    color = float3(newHsl.x, newSaturation, newLuminance);
    color = HSLToRGB(color);
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

technique DetintX
{
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader = UntintPass;
	}
}

//---FUCK---