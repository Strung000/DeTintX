//TintBeGone by Strung - v1.3.1

#include "ReShadeUI.fxh"
#include "ReShade.fxh"
#include "PD80_00_Color_Spaces.fxh" //this file from the prod80 repo is REQUIRED - get the whole prod80 shader repo (or just this file) to make this work

//---UI STUFF---

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
    ui_tooltip = "Saturation curve end.\n\nColors with higher luminance values than this are unaffected.";
> = 0.300;
uniform float desaturateShadowsMix < __UNIFORM_SLIDER_FLOAT1
    ui_category = "Shadow Desaturation";
    ui_label = "Mix";
    ui_tooltip = "Fade between full effect application and none.";
> = 0.950;

uniform float preserveLuminance < __UNIFORM_SLIDER_FLOAT1
    ui_category = "Detinting";
    ui_label = "Preserve Luminance";
	ui_tooltip = "Amount of luminance to preserve.";
> = 0.950;
uniform float detintRed < __UNIFORM_SLIDER_FLOAT1
    ui_min = 0;
    ui_max = 100;
    ui_category = "Detinting";
	ui_label = "Red";
	ui_tooltip = "Amount of red to remove.";
> = 4.5;
uniform float detintGreen < __UNIFORM_SLIDER_FLOAT1
    ui_min = 0;
    ui_max = 100;
    ui_category = "Detinting";
	ui_label = "Green";
	ui_tooltip = "Amount of green to remove.";
> = 7.5;
uniform float detintBlue < __UNIFORM_SLIDER_FLOAT1
    ui_min = 0;
    ui_max = 100;
    ui_category = "Detinting";
	ui_label = "Blue";
	ui_tooltip = "Amount of blue to remove.";
> = 0;
uniform float detintMix < __UNIFORM_SLIDER_FLOAT1
    ui_category = "Detinting";
    ui_label = "Mix";
    ui_tooltip = "Fade between full effect application and none.\n\nUse a low mix value with proportionally higher RGB values for finer tuning.\ne.g. rgb(0.01,0.02,0.00) @ 100% mix == rgb(0.10,0.20,0.00) @ 10% mix";
> = 0.950;

uniform int tuningBoost < __UNIFORM_SLIDER_FLOAT1
    ui_min = 1;
    ui_max = 10;
    ui_category = "Tuning";
    ui_label = "Boost";
	ui_tooltip = "Boost brightness to fine tune shadows.\n\nStare at a dark & neutrally colored area (e.g. what is meant to be a gray wall in a dark corner) and adjust values until the result is actually dark and gray.";
> = 1;


//---THE ACTUAL SHADER---

float3 UntintPass(float4 position : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
	float3 color = tex2D(ReShade::BackBuffer, texcoord).rgb;

    float3 oldHsl = RGBToHSL(color);

    float detintRedFloat = detintRed * 0.01f;
    float detintGreenFloat = detintGreen * 0.01f;
    float detintBlueFloat = detintBlue * 0.01f;

    float3 detintColor = float3(detintRedFloat, detintGreenFloat, detintBlueFloat);
    float3 detintedRgb = color - (detintColor * detintMix);

    detintedRgb = saturate(detintedRgb);

    float3 newHsl = RGBToHSL(detintedRgb);
	
	float newSaturation = newHsl.y;
	if (desaturateShadowsOn)
	{
		newSaturation = newHsl.y * saturate((newHsl.z - desaturateShadowsStart)/(desaturateShadowsEnd - desaturateShadowsStart + 0.01f));
		newSaturation = (newSaturation * desaturateShadowsMix) + (oldHsl.y * (1 - desaturateShadowsMix));
	}
    
    float newLuminance = (oldHsl.z * preserveLuminance) + (newHsl.z * (1.01f - preserveLuminance));

    color = float3(newHsl.x, newSaturation, newLuminance);
    color = HSLToRGB(color);

    if (tuningBoost > 1)
    {
        color *= tuningBoost;
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
