//DeTintX v2.0.1 - by Strung
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
> = 0.000;
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

//Advanced
uniform bool showClipping <
    ui_category = "Advanced";
    ui_label = "Show Clipping";
    ui_tooltip = "Invert clipped regions.";
> = false;
uniform int tuningBoost < __UNIFORM_SLIDER_INT1
    ui_min = 1;
    ui_max = 10;
    ui_category = "Advanced";
    ui_label = "Tuning Boost";
	ui_tooltip = "Boost output to fine tune shadows.";
> = 1;
uniform int lumaMode < 
    ui_category = "Advanced";
    ui_label = "Luma Coefficients";
    ui_type = "combo";
    ui_items = "Rec. 709 (sRGB)\0Rec. 2020 (HDR)\0Rec. 601 (SDTV)\0Adobe RGB\0";
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
    float c = cMax - cMin;

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
        float3(0.212f, 0.701f, 0.087f) * (mode == 3) //Adobe RGB
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
    inputRgb = saturate(inputRgb - 0.005f) + 0.005f;

    float inputLuma = rgb2luma(inputRgb);

    float lumaCoeff = targetLuma/inputLuma;

    float3 outputRgb = inputRgb * lumaCoeff;

    outputRgb -= 0.005f;

    return saturate(outputRgb);
}

//---PIXEL SHADER---
float3 UntintPass(float4 position : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
    //Get color
    float3 inputRgb = tex2D(ReShade::BackBuffer, texcoord);
    float3 inputHsl = rgb2hsl(inputRgb);

    //Input luma
    float inputLuma = rgb2luma(inputRgb);

    //Detinting
    float3 detintedRgb = inputRgb - (float3(detintRed, detintGreen, detintBlue) * (detintMix * detintOn));
    float3 detintedHsl = rgb2hsl(detintedRgb);

    //Shadow desaturation
    float preNormalSaturation = detintedHsl.y * saturate((detintedHsl.z - desaturateShadowsStart) / (desaturateShadowsEnd - desaturateShadowsStart));
    preNormalSaturation = (preNormalSaturation * (desaturateShadowsMix * desaturateShadowsOn)) + (detintedHsl.y * (1 - (desaturateShadowsMix * desaturateShadowsOn)));
    
    //Pre-normal color
    float3 preNormalHsl = float3(detintedHsl.x, preNormalSaturation, detintedHsl.z);
    float3 preNormalRgb = hsl2rgb(preNormalHsl);

    //Normalize to input luma
    float3 normalRgb = normalizeRgb(preNormalRgb, inputLuma);
    float3 normalHsl = rgb2hsl(normalRgb);

    //Lightness post-processing
    float outputLightness = normalHsl.z;

    //Levels
    outputLightness = (outputLightness - (blackLevel * levelsOn)) / (pow(whiteLevel, levelsOn) - blackLevel);

    //Shadow Boost
    outputLightness *= 1 + ((shadowBoostAmount * saturate((outputLightness - shadowBoostEnd) / (shadowBoostStart - shadowBoostEnd))) * shadowBoostOn);

    //Output color
    float3 outputHsl = float3(normalHsl.x, normalHsl.y, outputLightness);
    float3 outputRgb = hsl2rgb(outputHsl);

    //Show clipping
    bool clippingBelow = (outputRgb == float3(0, 0, 0)) && showClipping;
    bool clippingAbove = (outputRgb == float3(1, 1, 1)) && showClipping;
    outputRgb = (outputRgb * (!clippingBelow && !clippingAbove)) + (float3(1, 1, 1) * clippingBelow);

    //Tuning boost
    outputRgb *= tuningBoost;

    return outputRgb;
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