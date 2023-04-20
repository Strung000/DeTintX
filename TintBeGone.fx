//TintBeGone by Strung - v1.2

#include "ReShadeUI.fxh"
#include "ReShade.fxh"
#include "PD80_00_Color_Spaces.fxh" //this file from the prod80 repo is REQUIRED - get the whole prod80 shader repo (or just this file) to make this work

//---UI STUFF---

uniform bool desaturateShadowsOn <
	ui_category = "Shadow Desaturation";
    ui_label = "Desaturate Dhadows";
	ui_tooltip = "Desaturate darker areas for a more natural appearance.";
> = true;
uniform float desaturateShadowsPower < __UNIFORM_SLIDER_FLOAT1
    ui_category = "Shadow Desaturation";
    ui_label = "Power";
    ui_tooltip = "Shadow desaturation falloff.\n\nLower - Vertical curve, any color below offset goes grayscale\nHigher - Linear curve, saturation decreases gradually with luminance";
> = 0.300;
uniform float desaturateShadowsOffset < __UNIFORM_SLIDER_FLOAT1
    ui_category = "Shadow Desaturation";
    ui_label = "Offset";
    ui_tooltip = "Determines where the desaturation curve starts. Shadows are completely grayscale below this level of luminance.";
> = 0.010;
uniform float desaturateShadowsMultiplier < __UNIFORM_SLIDER_FLOAT1
    ui_category = "Shadow Desaturation";
    ui_label = "Multiplier";
    ui_tooltip = "Preserves mid and highlight saturation.\n\nLow - No change to curve\nHigh - Colors return to their original saturation earlier in the luminance curve.";
> = 0.200;
uniform float desaturateShadowsMix < __UNIFORM_SLIDER_FLOAT1
    ui_category = "Shadow Desaturation";
    ui_label = "Mix";
    ui_tooltip = "Fade between full effect application and none.";
> = 0.800;

uniform bool tuningMode <
	ui_category = "Detinting";
    ui_label = "Tuning Mode";
	ui_tooltip = "Stare at a dark & neutrally colored area (e.g. what is meant to be a gray wall in a dark corner) and adjust values until the result is actually dark and gray.";
> = false;
uniform float preserveLuminance < __UNIFORM_SLIDER_FLOAT1
    ui_category = "Detinting";
    ui_label = "Preserve Luminance";
	ui_tooltip = "Amount of luminance to preserve.";
> = 0.900;
uniform float detintRed < __UNIFORM_SLIDER_FLOAT1
    ui_category = "Detinting";
	ui_label = "Red";
	ui_tooltip = "Amount of red to remove.";
> = 0.035;
uniform float detintGreen < __UNIFORM_SLIDER_FLOAT1
    ui_category = "Detinting";
	ui_label = "Green";
	ui_tooltip = "Amount of green to remove.";
> = 0.055;

uniform float detintBlue < __UNIFORM_SLIDER_FLOAT1
    ui_category = "Detinting";
	ui_label = "Blue";
	ui_tooltip = "Amount of blue to remove.";
> = 0.000;

//---THE ACTUAL SHADER---

float3 UntintPass(float4 position : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
	float3 color = tex2D(ReShade::BackBuffer, texcoord).rgb;

    float3 oldHsl = RGBToHSL(color);

    float3 detintColor = float3(detintRed, detintGreen, detintBlue);
    float3 detintedRgb = color - detintColor;

    detintedRgb = saturate(detintedRgb);

    float3 newHsl = RGBToHSL(detintedRgb);
	
	float newSaturation = newHsl.y;
	if (desaturateShadowsOn)
	{
		newSaturation = newHsl.y * saturate((pow(saturate(newHsl.z - desaturateShadowsOffset), desaturateShadowsPower + 0.01f))/(1 - desaturateShadowsMultiplier));
		newSaturation = (newSaturation * desaturateShadowsMix) + (oldHsl.y * (1 - desaturateShadowsMix));
	}
    
    float newLuminance = (oldHsl.z * preserveLuminance) + (newHsl.z * (1.01f - preserveLuminance));

    color = float3(newHsl.x, newSaturation, newLuminance);
    color = HSLToRGB(color);

    if (tuningMode)
    {
        color *= 8;
        color = saturate(color);
    }

    return color;
}

technique TintBeGone
{
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader = UntintPass;
	}
}
