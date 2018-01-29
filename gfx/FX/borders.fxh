PixelShader = {
Code 
[[
	
	void GetPixelSubAreas( in float2 vInternalPoint, out float vArea0, out float vArea1, out float vArea2, out float vArea3 )
	{
		vArea0 = vInternalPoint.x * vInternalPoint.y;
		vArea1 = ( 1.f - vInternalPoint.x ) * vInternalPoint.y;
		vArea2 = vInternalPoint.x * ( 1.f - vInternalPoint.y );
		vArea3 = ( 1.f - vInternalPoint.x ) * ( 1.f - vInternalPoint.y );
	}
	
	void AddAreaToID( in float vID, in float vArea, inout float vTotals[9], inout float vIDs[9] )
	{
		for( int i = 0; i < 9; ++i ) 
		{
			vTotals[i] += vArea * ( 1 - saturate( abs( vIDs[i] - vID ) * 1000 ) );

			//if( vIDs[i] == vID )
			//{
			//	vTotals[i] += vArea;
			//	return;
			//}
		}
	}
	
	float GetBorderID( float2 vUV, out float vIntensity, in sampler2D BorderIDSampler, float vIDTextureSize )
	{
		int i;
		float vPX = 1.f / ( vIDTextureSize );
				
		float2 vPoints[9];
		vPoints[0] = float2(-vPX,-vPX);
		vPoints[1] = float2(0.f,-vPX);
		vPoints[2] = float2(vPX,-vPX);
		
		vPoints[3] = float2(-vPX,0.f);
		vPoints[4] = float2(0.f,0.f);
		vPoints[5] = float2(vPX,0.f);
		
		vPoints[6] = float2(-vPX,vPX);
		vPoints[7] = float2(0.f,vPX);
		vPoints[8] = float2(vPX,vPX);
		
		float vIDs[9];
		float vTotals[9];
		for( i = 0; i < 9; ++i )
			vTotals[i] = 0.f;
			
		for( i = 0; i < 9; ++i )
			vIDs[i] = tex2Dlod0( BorderIDSampler, vUV + vPoints[i] ).a;

		// If all texture reads give the same ID, skip out the really expensive calculations below. 
		// This early out dramatically increases performance (better than halves the render time).
		if ( (vIDs[0] == vIDs[1]) && (vIDs[0] == vIDs[2]) && (vIDs[0] == vIDs[3]) && (vIDs[0] == vIDs[4]) && 
			 (vIDs[0] == vIDs[5]) && (vIDs[0] == vIDs[6]) && (vIDs[0] == vIDs[7]) && (vIDs[0] == vIDs[8]) )
		{
			vIntensity = (vIDs[0] == 0) ? 0.0f : 1.0f;
			return vIDs[0];
		}     
		
		float2 vInternal = vec2( 1.f ) - frac( vUV * vIDTextureSize );
			
		float vAreas[4];
		GetPixelSubAreas( vInternal, vAreas[0], vAreas[1], vAreas[2], vAreas[3] );
		
		//IDs:	0 1 2	Areas: 	0 1
		//		3 4 5			2 3
		//		6 7 8
		
		// For each "quad" (corner), if all 4 parts are the same, we can just apply a weight
		// of 1 and skip sampling/weighting for each "sub-area".
		
		//First quad
		if ( ((vIDs[0] == vIDs[1]) && (vIDs[0] == vIDs[3]) && (vIDs[0] == vIDs[4])) )
		{
			AddAreaToID( vIDs[0], 1.0, vTotals, vIDs );
		}
		else 
		{
			AddAreaToID( vIDs[0], vAreas[0], vTotals, vIDs );
			AddAreaToID( vIDs[1], vAreas[1], vTotals, vIDs );
			AddAreaToID( vIDs[3], vAreas[2], vTotals, vIDs );
			AddAreaToID( vIDs[4], vAreas[3], vTotals, vIDs );
		}
				                                
		//Second quad                           
		if ( ((vIDs[1] == vIDs[2]) && (vIDs[1] == vIDs[4]) && (vIDs[1] == vIDs[5])) )
		{
			AddAreaToID( vIDs[1], 1.0, vTotals, vIDs );
		}
		else 
		{
			AddAreaToID( vIDs[1], vAreas[0], vTotals, vIDs );
			AddAreaToID( vIDs[2], vAreas[1], vTotals, vIDs );
			AddAreaToID( vIDs[4], vAreas[2], vTotals, vIDs );
			AddAreaToID( vIDs[5], vAreas[3], vTotals, vIDs );
		}
		                                       
		//Third quad                           
		if ( ((vIDs[3] == vIDs[4]) && (vIDs[3] == vIDs[6]) && (vIDs[3] == vIDs[7])) )
		{	
			AddAreaToID( vIDs[3], 1.0, vTotals, vIDs );
		}
		else 
		{
			AddAreaToID( vIDs[3], vAreas[0], vTotals, vIDs );
			AddAreaToID( vIDs[4], vAreas[1], vTotals, vIDs );
			AddAreaToID( vIDs[6], vAreas[2], vTotals, vIDs );
			AddAreaToID( vIDs[7], vAreas[3], vTotals, vIDs );
		}		

		//Fourth quad                          
		if ( ((vIDs[4] == vIDs[5]) && (vIDs[4] == vIDs[7]) && (vIDs[4] == vIDs[8])) )
		{
			AddAreaToID( vIDs[4], 1.0, vTotals, vIDs );
		}
		else 
		{
			AddAreaToID( vIDs[4], vAreas[0], vTotals, vIDs );
			AddAreaToID( vIDs[5], vAreas[1], vTotals, vIDs );
			AddAreaToID( vIDs[7], vAreas[2], vTotals, vIDs );
			AddAreaToID( vIDs[8], vAreas[3], vTotals, vIDs );
		}	
		
		int nMax = 0;
		for( i = 1; i < 9; ++i )
		{
			//nMax += ( i - nMax ) * ( 1 - saturate( ( vTotals[nMax] - vTotals[i] ) * 1000 ) );

			if( vTotals[nMax] <= vTotals[i] )
			{
				nMax = i;
			}
		} 
		
		vIntensity = vTotals[nMax] / 4.f;
		return vIDs[nMax];
	}

	float GetBorderID_Bilinear( float2 vUV, out float vIntensity, in sampler2D BorderIDSampler, float vIDTextureSize )
	{
		int i;
		float vPX = 1.f / ( vIDTextureSize );
		float2 vPixel = vUV * ( vIDTextureSize );
		
		float2 vInternal = frac( vPixel );
		//if( min( vInternal.x, vInternal.y ) < 0.025f || max( vInternal.x, vInternal.y ) > 0.//975f )
		//{
		//	if( tex2D( BorderIDSampler, v.vUV ).a > 0.0f )
		//		return 0.5f;
		//	return 1.f; 
		//}
					
		float2 vPoints[4];
		float vWeights[4];
		for( i = 0; i < 4; ++i )
			vPoints[i] = vPixel;
			
		if( vInternal.x < 0.5f )
		{
			vPoints[0].x -= 1;
			vPoints[2].x -= 1;
			vInternal.x += 0.5f;
		}
		else
		{
			vPoints[1].x += 1;
			vPoints[3].x += 1;
			vInternal.x -= 0.5f;
		}
		
		if( vInternal.y < 0.5f )
		{
			vPoints[0].y -= 1;
			vPoints[1].y -= 1;
			vInternal.y += 0.5f;
		}
		else
		{
			vPoints[2].y += 1;
			vPoints[3].y += 1;
			vInternal.y -= 0.5f;
		}
		
		vWeights[0] = ( 1.f - vInternal.x ) * ( 1.f - vInternal.y );
		vWeights[1] = vInternal.x * ( 1.f - vInternal.y );
		vWeights[2] = ( 1.f - vInternal.x ) * vInternal.y;
		vWeights[3] = vInternal.x * vInternal.y;
		
		float vID[4];
		for( i = 0; i < 4; ++i )
		{
			vID[i] = tex2D( BorderIDSampler, vPoints[i] * vPX ).a;
			
			for( int j = 0; j < i; ++j )
			{
				if( vID[i] == vID[j] )
				{
					vWeights[j] += vWeights[i];
				}
			}
		}
		
		int nMax = 0;
		for( i = 1; i < 4; ++i )
		{
			if( vWeights[i] > vWeights[nMax] )
			{
				nMax = i;
			}
		} 
		
		vIntensity = vWeights[nMax];
		return vID[nMax];
	}	
	
	float4 GetBorderColor( float2 vWorldUV, in sampler2D BorderIDSampler, float vIDTextureSize, in sampler2D BorderColorSampler)
	{	
		//float vCountry = tex2D( BorderIDSampler, vWorldUV ).a;
		//return vCountry * 20.f;
			
		float vIntensity = 0.f;

	#if defined(SHADERQUALITY_LOW)
		float vCountry = GetBorderID_Bilinear( vWorldUV, vIntensity, BorderIDSampler, vIDTextureSize );
	#else
		float vCountry = GetBorderID( vWorldUV, vIntensity, BorderIDSampler, vIDTextureSize );
	#endif
		
		const int nColorTextureHeight = 8;
		const float vStripeWidth = 1.f;
		float vNumColors = tex2Dlod0( BorderColorSampler, float2( vCountry, 0.0f ) ).b * 255;
		if( vNumColors <= 0.f )
		{
			return vec4( 0.0f );
		}
		float4 vColor;
		if( vNumColors <= 1.1f )
		{
			vColor = tex2Dlod0( BorderColorSampler, float2( vCountry, 1.0f / nColorTextureHeight ) );
		}
		else
		{
			float vColorIndex1 = mod( ( 1000.f + vWorldUV.x - vWorldUV.y ) * 200.f / vStripeWidth, vNumColors );
			//float vColorIndex2 = mod( vColorIndex1 + 1.f, vNumColors );
			//vColorIndex2 = mod( vColorIndex2, vNumColors );
			float4 vColor1 = tex2Dlod0( BorderColorSampler, float2( vCountry, floor( vColorIndex1 + 1.0f ) / nColorTextureHeight ) );
			//float4 vColor2 = tex2Dlod0( BorderColorSampler, float2( vCountry, floor( vColorIndex2 + 1.0f ) / nColorTextureHeight ) );
			
			//float vBlendRange = 0.015f;
			//float vAlpha = saturate( max( frac( vColorIndex1 ) - 1.f + vBlendRange, vBlendRange - frac( vColorIndex1 ) ) ) / ( vBlendRange * 2 );
			////return floor( vColorIndex2 ) / 3.f;
			////float vAlpha = saturate( ( max( frac(vColorIndex1), 1.f - frac(vColorIndex1) ) - 0.25f ) * 4.f );
			//vColor = lerp( vColor1, vColor2, vAlpha );
			vColor = vColor1;
		}
		#ifdef PDX_OPENGL
			vColor.rb = vColor.br;
		#endif
		
		//vColor.rgb *= smoothstep( 1.5f, 0.6f, vIntensity );
		//if( vIntensity < 0.52f )
		//	vColor.a = 0.f;

		vColor.rgb *= saturate( smoothstep( 0.5f, 0.57f, vIntensity ) );
		vColor.a *= saturate( smoothstep( 0.45f, 0.55f, vIntensity ) );
		
		return vColor;
	}
]]
}
