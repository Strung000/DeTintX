//DeTintX v2.2 - by Strung
//Visit GitHub page for info - https://github.com/Strung000/DetintX

#include "ReShadeUI.fxh"
#include "ReShade.fxh"

//---UI---
//Detinting
uniform bool detintOn <
    ui_category = "Detinting";
    ui_label = "Detinting";
    ui_tooltip = "Subtract color from input.";
> = true;
uniform float detintRed < __UNIFORM_SLIDER_FLOAT1
    ui_category = "Detinting";
    ui_label = "Red";
    ui_tooltip = "Amount of red to remove.";
> = 0.035;
uniform float detintGreen < __UNIFORM_SLIDER_FLOAT1
    ui_category = "Detinting";
    ui_label = "Green";
    ui_tooltip = "Amount of green to remove.";
> = 0.060;
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
    ui_min = 0.005;
    ui_category = "Shadow Desaturation";
    ui_label = "Start";
    ui_tooltip = "Saturation curve start.\n\nColors with lower lightness values than this are fully desaturated.";
> = 0.015;
uniform float desaturateShadowsEnd < __UNIFORM_SLIDER_FLOAT1
    ui_min = 0.005;
    ui_category = "Shadow Desaturation";
    ui_label = "End";
    ui_tooltip = "Saturation curve end.\n\nColors with higher lightness values than this are not desaturated.";
> = 0.125;
uniform float desaturateShadowsMix < __UNIFORM_SLIDER_FLOAT1
    ui_category = "Shadow Desaturation";
    ui_label = "Mix";
    ui_tooltip = "Amount to blend with input saturation.";
> = 1.00;

uniform float normalizationMix < __UNIFORM_SLIDER_FLOAT1
    ui_category = "Normalization";
    ui_label = "Mix";
    ui_tooltip = "Amount to restore original luma.";
> = 1;

uniform bool levelsOn < __UNIFORM_SLIDER_FLOAT1
    ui_category = "Levels";
    ui_label = "Levels";
    ui_tooltip = "Adjust black and white levels.";
> = true;
uniform float levelsBlack < __UNIFORM_SLIDER_FLOAT1
    ui_category = "Levels";
    ui_label = "Black";
    ui_tooltip = "Brightness level below where colors become pure black.";
> = 0.01;
uniform float levelsWhite < __UNIFORM_SLIDER_FLOAT1
    ui_category = "Levels";
    ui_label = "White";
    ui_tooltip = "Brightness level above where colors become pure white.";
> = 1;

//Advanced
uniform bool showClipping <
    ui_category = "Advanced";
    ui_label = "Show Clipping";
    ui_tooltip = "Invert clipped regions.";
> = false;
uniform int tuningBoost < __UNIFORM_SLIDER_INT1
    ui_min = 1;
    ui_max = 20;
    ui_category = "Advanced";
    ui_label = "Tuning Boost";
	ui_tooltip = "Boost output to fine tune shadows.";
> = 1;
uniform int lumaMode < 
    ui_category = "Advanced";
    ui_label = "Luma Coefficients";
    ui_type = "combo";
    ui_items = "Rec. 709 (sRGB)\0Rec. 2020 (HDR)\0Rec. 601 (SDTV)\0Adobe RGB\0Component Average\0";
    ui_tooltip = "Luma coefficients to use during luma preservation.";
> = 0;

//---FUNCTIONS---
float3 rgb2hsl(float3 rgb)
{
    float r = saturate(rgb.r);
    float g = saturate(rgb.g);
    float b = saturate(rgb.b);

    //Chroma
    float cMax = max(r, max(g, b));
    float cMin = min(r, min(g, b));
    float c = (cMax - cMin) + 0.001f;

    //Lightness
    float l = (cMax + cMin) / 2;

    //Saturation
    float s = c / (1 - abs((2 * l) - 1));

    //Hue
    float h = ((((g - b) * (cMax == r)) + ((b - r) * (cMax == g)) + ((r - g) * (cMax == b))) / c) + (2 * (cMax == g)) + (4 * (cMax == b));
    h += 6 * (h < 0);

    return float3(h, s, l);
}

float3 hsl2rgb (float3 hsl)
{
    //HSL
    float h = hsl.x;
    float s = saturate(hsl.y);
    float l = saturate(hsl.z);

    //Chroma
    float c = (1 - abs((2 * l) - 1)) * s;

    //Intermediate
    float x = c * (1 - abs((h % 2) - 1));

    //RGB
    float r = (c * (((h >= 0) && (h < 1)) || ((h >= 5) && (h < 6)))) + (x * (((h >= 1) && (h < 2)) || ((h >= 4) && (h < 5))));
    float g = (c * ((h >= 1) && (h < 3))) + (x * (((h >= 0) && (h < 1)) || ((h >= 3) && (h < 4))));
    float b = (c * ((h >= 3) && (h < 5))) + (x * (((h >= 2) && (h < 3)) || ((h >= 5) && (h < 6))));
    float3 rgb = float3(r, g, b);

    //Luminance offset
    float m = l - (c / 2);

    rgb += m;
    
    return rgb;
}

float3 getLumaCoeffs (int mode)
{
    float3 output =
        float3(0.213f, 0.715f, 0.072f) * (mode == 0) + //Rec. 709 (sRGB)
        float3(0.263f, 0.678f, 0.059f) * (mode == 1) + //Rec. 2020 (HDR)
        float3(0.299f, 0.587f, 0.114f) * (mode == 2) + //Rec. 601 (SDTV)
        float3(0.212f, 0.701f, 0.087f) * (mode == 3) + //Adobe RGB
        float3(0.333f, 0.333f, 0.333f) * (mode == 4) //Component Average
    ;

    return output;
}

float rgb2luma (float3 rgb)
{
    float3 lumaCoeffs = getLumaCoeffs(lumaMode);
    float luma = (rgb.r * lumaCoeffs.x) + (rgb.g * lumaCoeffs.y) + (rgb.b * lumaCoeffs.z);
    return luma;
}

float3 normalizeRgb (float3 inputRgb, float targetLuma)
{
    float inputLuma = rgb2luma(inputRgb);

    float lumaCoeff = targetLuma/(inputLuma + 0.005f);

    float3 outputRgb = (inputRgb + 0.005f) * lumaCoeff;

    return saturate(outputRgb);
}

//---PIXEL SHADER---
float3 UntintPass(float4 position : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
    //Get color
    float3 inputRgb = tex2D(ReShade::BackBuffer, texcoord);
    float3 inputHsl = rgb2hsl(inputRgb);

    //Initial luma
    float initialLuma = rgb2luma(inputRgb);

    //Detinting
    float3 detintedRgb = inputRgb - (float3(detintRed, detintGreen, detintBlue) * (detintMix * detintOn));
    float3 detintedHsl = rgb2hsl(detintedRgb);

    float preNormalSaturation = detintedHsl.y * (saturate((detintedHsl.z - desaturateShadowsStart) / (desaturateShadowsEnd - desaturateShadowsStart)));
    preNormalSaturation = (preNormalSaturation * ((desaturateShadowsMix) * desaturateShadowsOn)) + (detintedHsl.y * (1 - ((desaturateShadowsMix) * desaturateShadowsOn)));

    //Pre-normal color
    float3 preNormalHsl = float3(detintedHsl.x, preNormalSaturation, detintedHsl.z);
    float3 preNormalRgb = hsl2rgb(preNormalHsl);

    //Normalize to initial luma
    float3 normalRgb = normalizeRgb(preNormalRgb, initialLuma);
    float3 outputRgb = (preNormalRgb * (1 - normalizationMix)) + (normalRgb * normalizationMix);

    //Levels
    outputRgb = (outputRgb - (levelsBlack * levelsOn)) / (pow(levelsWhite, levelsOn) - levelsBlack);
    outputRgb = saturate(outputRgb);

    //Show clipping
    bool clippingBelow = (rgb2luma(outputRgb) <= 0) && showClipping;
    bool clippingAbove = (rgb2luma(outputRgb) >= 1) && showClipping;
    outputRgb = (outputRgb * (!clippingBelow && !clippingAbove)) + (float3(1, 1, 1) * clippingBelow);

    //Tuning boost
    outputRgb *= tuningBoost;

    return saturate(outputRgb);
}

//---TECHNIQUE---
technique DeTintX
{
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader = UntintPass;
	}
}
