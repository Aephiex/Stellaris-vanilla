PixelShader = 
{
	ConstantBuffer( TiledPointLight, 4, 62 ) # after shadowmap constants
	{
		float4 GridStart_InvCellSize;
	}

	Code
		ConstantBuffers = { TiledPointLight }
	[[

	static const float2 INV_LIGHT_INDEX_TEXTURE_SIZE = float2(1.0 / 64.0, 1.0 / 64.0);
	static const float INV_LIGHT_DATA_TEXTURE_SIZE = float(1.0 / 128.0);

	float2 GetLightIndexUV(float3 WorldSpacePos)
	{
		float2 XZ = WorldSpacePos.xz;
		XZ -= GridStart_InvCellSize.xy;
		
		float2 cellIndex = XZ * GridStart_InvCellSize.zw;
		return cellIndex * INV_LIGHT_INDEX_TEXTURE_SIZE;
	}

	void CalculatePointLights(LightingProperties aProperties, in sampler2D LightData_, in sampler2D LightIndexMap_, inout float3 aDiffuseLightOut, inout float3 aSpecularLightOut)
	{
		float4 vScreenSpace = mul( ViewProjectionMatrix, float4(aProperties._WorldSpacePos,1.0f) );
		
		float4 vScreenCoord;
		vScreenCoord.x = ( vScreenSpace.x * 0.5 + vScreenSpace.w * 0.5 );
		vScreenCoord.y = ( vScreenSpace.w * 0.5 + vScreenSpace.y * 0.5 );
		vScreenCoord.zw = vScreenSpace.ww;
		float4 LightIndices = tex2Dproj(LightIndexMap_, vScreenCoord );
		
		for (int i = 0; i < 4; ++i)
		{
			float LightIndex = LightIndices[i] * 255.0;
			if (LightIndex >= 255.0)
				break;
			
			float4 LightData1 = tex2Dlod(LightData_, float4((LightIndex * 2 + 0.5) * INV_LIGHT_DATA_TEXTURE_SIZE, 0, 0, 0));
			float4 LightData2 = tex2Dlod(LightData_, float4((LightIndex * 2 + 1.5) * INV_LIGHT_DATA_TEXTURE_SIZE, 0, 0, 0));
			PointLight pointlight = GetPointLight(LightData1, LightData2);
				
			CalculatePointLight(pointlight, aProperties, aDiffuseLightOut, aSpecularLightOut);
		}
	}

	]]
}