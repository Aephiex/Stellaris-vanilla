#pragma warning (disable: 5203)

#define PDX_ORBIS

#define GetMatrixData( Matrix, row, col ) ( Matrix [ row ] [ col ] )
#define FIX_FLIPPED_UV( X ) ( X )

float3x3 CastTo3x3( in float4x4 M )
{
	return (float3x3)M;
}
#define Create3x3 float3x3
#define Create4x4 float4x4

#define mod(x,y) fmod(x,y)

float2 vec2(float vValue) { return float2(vValue, vValue); }
float3 vec3(float vValue) { return float3(vValue, vValue, vValue); }
float4 vec4(float vValue) { return float4(vValue, vValue, vValue, vValue); }

#define PDX_POSITION S_POSITION

#define PDX_COLOR S_TARGET_OUTPUT

struct sampler2D
{
    Texture2D _Texture;
    SamplerState _Sampler;
};
sampler2D CreateSampler2D(Texture2D Texture, SamplerState Sampler)
{
    sampler2D ret = { Texture, Sampler };
    return ret;
}

struct samplerCube
{
    TextureCube _Texture;
    SamplerState _Sampler;
};
samplerCube CreateSamplerCube(TextureCube Texture, SamplerState Sampler)
{
    samplerCube ret = { Texture, Sampler };
    return ret;
}

#define sampler2DShadow sampler2D

#define tex2D(samp,uv) samp._Texture.Sample(samp._Sampler, uv)
#define tex2Dlod(samp,uv_lod) samp._Texture.SampleLOD(samp._Sampler, (uv_lod).xy, (uv_lod).w)
#define tex2Dlod0(samp,uv) samp._Texture.SampleLOD(samp._Sampler, (uv), 0.0)
#define tex2Dbias(samp,uv_bias) samp._Texture.SampleBias(samp._Sampler, (uv_bias).xy, (uv_bias).w)
#define tex2Dproj(samp,uv_proj) samp._Texture.SampleLOD(samp._Sampler, (uv_proj).xy / (uv_proj).w, 0)

#define texCUBE(samp,uv) samp._Texture.Sample(samp._Sampler, uv)
#define texCUBElod(samp,uv_lod) samp._Texture.SampleLOD(samp._Sampler, (uv_lod).xyz, (uv_lod).w)
#define texCUBEbias(samp,uv_bias) samp._Texture.SampleBias(samp._Sampler, (uv_bias).xyz, (uv_bias).w)

#ifdef PIXEL_SHADER
#ifdef IS_SHADOW
#pragma PSSL_target_output_format(default FMT_32_ABGR)
#endif
#endif