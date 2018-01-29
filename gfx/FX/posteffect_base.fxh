ConstantBuffer( PostEffect, 1, 32 )
{
	float4 HSV;
	float3 ColorBalance;
	float EmissiveBloomStrength;
	float2 InvDownSampleSize;
	float2 InvWindowSize;
	float2 BloomToScreenScale;
	float2 LensToScreenScale;
	float BrightThreshold;
	float MiddleGrey;
	float LumWhite2;
};