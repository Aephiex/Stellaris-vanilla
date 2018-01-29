PixelShader = 
{
	ConstantBuffer( Shadow, 3, 50 )
	{
		float4 ShadowMapTextureMatrix0XAxis;
		float4 ShadowMapTextureMatrix0YAxis;
		float4 ShadowMapTextureMatrix0ZAxis;
		float4 ShadowMapTextureMatrix1XAxis;
		float4 ShadowMapTextureMatrix1YAxis;
		float4 ShadowMapTextureMatrix1ZAxis;
		float4 ShadowMapTextureMatrix2XAxis;
		float4 ShadowMapTextureMatrix2YAxis;
		float4 ShadowMapTextureMatrix2ZAxis;
		float4 ShadowMapTextureMatrix3XAxis;
		float4 ShadowMapTextureMatrix3YAxis;
		float4 ShadowMapTextureMatrix3ZAxis;
	};

	Code
		ConstantBuffers = { Shadow }
	[[

	//#define PDX_FOUR_SPLITS
	#ifdef PDX_FOUR_SPLITS
	static const float2 shadowMapSize = float2(2048.0f, 2048.0f);
	#else
	static const float2 shadowMapSize = float2(3072.0f, 1024.0f);
	#endif

	float GetShadowPCF( float4 vShadowProj, float vZBias, sampler2DShadow ShadowSample )
	{
		float fShadowTerm1 = tex2Dproj( ShadowSample, vShadowProj ).r < (vShadowProj.z - vZBias) ? 0.0f : 1.0f;
		float fShadowTerm2 = tex2Dproj( ShadowSample, vShadowProj + float4( 1.0f / shadowMapSize.x, 0.0f, 0.0f, 0.0f ) ).r < (vShadowProj.z - vZBias) ? 0.0f : 1.0f;
		float fShadowTerm3 = tex2Dproj( ShadowSample, vShadowProj + float4( 0.0f, 1.0f / shadowMapSize.y, 0.0f, 0.0f ) ).r < (vShadowProj.z - vZBias) ? 0.0f : 1.0f;
		float fShadowTerm4 = tex2Dproj( ShadowSample, vShadowProj + float4( 1.0f / shadowMapSize.x, 1.0f / shadowMapSize.y, 0.0f, 0.0f ) ).r < (vShadowProj.z - vZBias) ? 0.0f : 1.0f;

		float2 f = frac(vShadowProj.xy * shadowMapSize);
		//return fShadowTerm1;
		return lerp(lerp(fShadowTerm1, fShadowTerm2, f.x), lerp(fShadowTerm3, fShadowTerm4, f.x), f.y);
	}

	float GetShadowMultiTap( float4 vShadowProj, float vZBias, sampler2DShadow ShadowSample )
	{
		float2 fTexelSize = float2(0.7f / shadowMapSize.x, 0.7f / shadowMapSize.y);
		float4 shadowFactor;
		shadowFactor.x = GetShadowPCF(vShadowProj + float4( -fTexelSize.x, 0.0f, 0.0f, 0.0f ), vZBias, ShadowSample);
		shadowFactor.y = GetShadowPCF(vShadowProj + float4( 0.0f, fTexelSize.y, 0.0f, 0.0f ), vZBias, ShadowSample);
		shadowFactor.z = GetShadowPCF(vShadowProj + float4( fTexelSize.x, 0.0f, 0.0f, 0.0f ), vZBias, ShadowSample);
		shadowFactor.w = GetShadowPCF(vShadowProj + float4( 0.0f, -fTexelSize.y, 0.0f, 0.0f ), vZBias, ShadowSample);
		return dot(shadowFactor, float4(0.25f, 0.25f, 0.25f, 0.25f));
	}

	float GetShadow( float4 vShadowProj, float vZBias, sampler2DShadow ShadowSample )
	{
	#define SHADOW_MULTI_TAP
	#ifdef SHADOW_MULTI_TAP
		return GetShadowMultiTap(vShadowProj, vZBias, ShadowSample);
	#else
		#ifdef SHADOW_PCF
			return GetShadowPCF(vShadowProj, vZBias, ShadowSample);
		#else
			return tex2Dproj(ShadowSample, vShadowProj).r < (vShadowProj.z - vZBias) ? 0.0f : 1.0f;
		#endif
	#endif
	}

	#ifdef PDX_FOUR_SPLITS
	static const float4 scale = float4(0.5, 0.5, 1, 1);
	static const float4 offset1 = float4(0.5, 0.0, 0, 0);
	static const float4 offset2 = float4(0.0, 0.5, 0, 0);
	static const float4 offset3 = float4(0.5, 0.5, 0, 0);
	#else
	static const float4 scale = float4(1.0 / 3.0, 1, 1, 1);
	static const float4 offset1 = float4(1.0 / 3.0, 0, 0, 0);
	static const float4 offset2 = float4(2.0 / 3.0, 0, 0, 0);
	#endif

	float CalculateShadowCascaded( float3 WorldSpacePos, sampler2DShadow ShadowMap_ )
	{
		float4 WorldPos = float4(WorldSpacePos, 1.0f);
		
		float zBias = 0.001f;
		float4 shadowCoord = float4(0, 0, 0, 1);
		shadowCoord.x = dot(ShadowMapTextureMatrix0XAxis, WorldPos);
		shadowCoord.y = dot(ShadowMapTextureMatrix0YAxis, WorldPos);
			
		float2 edge = min(shadowCoord.xy, float2(1.0, 1.0) - shadowCoord.xy);
		const float cutoff = 2.0f / 1024.0f;
		if (edge.x < cutoff || edge.y < cutoff)
		{
			shadowCoord.x = dot(ShadowMapTextureMatrix1XAxis, WorldPos);
			shadowCoord.y = dot(ShadowMapTextureMatrix1YAxis, WorldPos);
			
			edge = min(shadowCoord.xy, float2(1.0, 1.0) - shadowCoord.xy);
			if (edge.x < cutoff || edge.y < cutoff)
			{
				shadowCoord.x = dot(ShadowMapTextureMatrix2XAxis, WorldPos);
				shadowCoord.y = dot(ShadowMapTextureMatrix2YAxis, WorldPos);
				
	#ifdef PDX_FOUR_SPLITS
				edge = min(shadowCoord.xy, float2(1.0, 1.0) - shadowCoord.xy);
				if (edge.x < cutoff || edge.y < cutoff)
				{
					shadowCoord.x = dot(ShadowMapTextureMatrix3XAxis, WorldPos);
					shadowCoord.y = dot(ShadowMapTextureMatrix3YAxis, WorldPos);
					
					edge = min(shadowCoord.xy, float2(1.0, 1.0) - shadowCoord.xy);
					if (edge.x > cutoff && edge.y > cutoff)
					{
						shadowCoord.z = dot(ShadowMapTextureMatrix3ZAxis, WorldPos);
						shadowCoord = shadowCoord * scale + offset3;
					}
				}
				else
				{
					shadowCoord.z = dot(ShadowMapTextureMatrix2ZAxis, WorldPos);
					shadowCoord = shadowCoord * scale + offset2;
					zBias = 0.0006f;
				}
	#else				
				edge = min(shadowCoord.xy, float2(1.0, 1.0) - shadowCoord.xy);
				if (edge.x > cutoff && edge.y > cutoff)
				{
					shadowCoord.z = dot(ShadowMapTextureMatrix2ZAxis, WorldPos);
					shadowCoord = shadowCoord * scale + offset2;
					zBias = 0.0006f;
				}
	#endif
			}
			else
			{
				shadowCoord.z = dot(ShadowMapTextureMatrix1ZAxis, WorldPos);
				shadowCoord = shadowCoord * scale + offset1;
				zBias = 0.0004f;
			}
		}
		else
		{
			shadowCoord.z = dot(ShadowMapTextureMatrix0ZAxis, WorldPos);
			shadowCoord = shadowCoord * scale;
			zBias = 0.0003f;
		}
		
		return GetShadow(shadowCoord, zBias, ShadowMap_);
	}

	float3 CalculateShadowCascadedDebugColor( float3 WorldSpacePos )
	{
		float4 WorldPos = float4(WorldSpacePos, 1.0f);
		
		float3 retColor = float3(1,0,0);
		
		float2 shadowCoord;
		shadowCoord.x = dot(ShadowMapTextureMatrix0XAxis, WorldPos);
		shadowCoord.y = dot(ShadowMapTextureMatrix0YAxis, WorldPos);

		float2 edge = min(shadowCoord.xy, float2(1.0, 1.0) - shadowCoord.xy);
		const float cutoff = 2.0f / 1024.0f;
		if (edge.x < cutoff || edge.y < cutoff)
		{
			retColor = float3(0,1,0);
			
			shadowCoord.x = dot(ShadowMapTextureMatrix1XAxis, WorldPos);
			shadowCoord.y = dot(ShadowMapTextureMatrix1YAxis, WorldPos);
			
			edge = min(shadowCoord.xy, float2(1.0, 1.0) - shadowCoord.xy);
			if (edge.x < cutoff || edge.y < cutoff)
			{
				retColor = float3(0,0,1);
			
				shadowCoord.x = dot(ShadowMapTextureMatrix2XAxis, WorldPos);
				shadowCoord.y = dot(ShadowMapTextureMatrix2YAxis, WorldPos);
				
				edge = min(shadowCoord.xy, float2(1.0, 1.0) - shadowCoord.xy);
				if (edge.x < cutoff || edge.y < cutoff)
				{
	#ifdef PDX_FOUR_SPLITS
					retColor = float3(1,1,0);
					
					shadowCoord.x = dot(ShadowMapTextureMatrix3XAxis, WorldPos);
					shadowCoord.y = dot(ShadowMapTextureMatrix3YAxis, WorldPos);
								
					edge = min(shadowCoord.xy, float2(1.0, 1.0) - shadowCoord.xy);
					if (edge.x < cutoff || edge.y < cutoff)
					{
						retColor = float3(0,0,0);
					}
	#else
					retColor = float3(0,0,0);
	#endif
				}
			}
		}
		
		return retColor;
	}

	]]
}