Includes = {
	"constants.fxh"
	"standardfuncsgfx.fxh"
	"tiled_pointlights.fxh"
}

PixelShader =
{
	Samplers =
	{
		DiffuseMap = 
		{
			Index = 0;
			MinFilter = "Linear"
			MagFilter = "Linear"
			MipFilter = "Linear"
			AddressU = "Wrap"
			AddressV = "Wrap"
		}
		
		SpecularMap = 
		{
			Index = 1
			MinFilter = "Linear"
			MagFilter = "Linear"
			MipFilter = "Linear"
			AddressU = "Wrap"
			AddressV = "Wrap"
		}
		
		NormalMap = 
		{
			Index = 2
			MinFilter = "Linear"
			MagFilter = "Linear"
			MipFilter = "Linear"
			AddressU = "Wrap"
			AddressV = "Wrap"
		}
		
		EnvironmentMap =
		{
			Index = 4
			MagFilter = "Linear"
			MinFilter = "Linear"
			MipFilter = "Linear"
			AddressU = "Clamp"
			AddressV = "Clamp"
			Type = "Cube"
		}
		LightIndexMap =
		{
			Index = 5
			MagFilter = "Point"
			MinFilter = "Point"
			MipFilter = "Point"
			AddressU = "Clamp"
			AddressV = "Clamp"
		}
		LightDataMap =
		{
			Index = 6
			MagFilter = "Point"
			MinFilter = "Point"
			MipFilter = "Point"
			AddressU = "Clamp"
			AddressV = "Clamp"
		}	
	}
}

VertexStruct VS_INPUT
{
    float3 	vPosition				: POSITION;
	float3 	vNormal      			: TEXCOORD0;
	float4 	vTangent				: TEXCOORD1;
	float2 	vUV0					: TEXCOORD2;
	float2 	vUV1					: TEXCOORD3;
	float3 	vInstanceOffset 		: TEXCOORD4;
	float4 	vInstanceRotationSize	: TEXCOORD5;
};

VertexStruct VS_OUTPUT
{
    float4 vPosition	: PDX_POSITION;
	float3 vNormal		: TEXCOORD0;
	float3 vTangent		: TEXCOORD1;
	float3 vBitangent	: TEXCOORD2;
	float2 vUV0			: TEXCOORD3;
	float2 vUV1			: TEXCOORD4;
	float4 vPos			: TEXCOORD5;
};

ConstantBuffer( Animation, 3, 50 )
{
	float	 TimeRot;
};

VertexShader =
{
	MainCode AsteroidVertexShader
		ConstantBuffers = { Common, Animation, TiledPointLight }
	[[
		VS_OUTPUT main(const VS_INPUT v )
		{
			VS_OUTPUT Out;
					
			float4 vPosition = float4( v.vPosition.xyz, 1.0f );
			
			float3 vRotationDir = v.vInstanceRotationSize.xyz;
			
			float randSin = sin( TimeRot );
			float randCos = cos( TimeRot );
			
			vRotationDir.xz = float2( 
			vRotationDir.x * randCos - vRotationDir.z * randSin, 
			vRotationDir.x * randSin + vRotationDir.z * randCos );		
			
			// Calculate rotation matrix from rotation direction
			float3 vUp 				= normalize( float3( 0.0f, 1.0f, 0.0f ) );
			float3 zaxis 			= normalize( vRotationDir ); //Dir
			float3 xaxis 			= normalize( cross( vUp, zaxis ) );
			float3 yaxis 			= normalize( cross( zaxis, xaxis ) );
			float3x3 RotationMatrix = Create3x3( xaxis, yaxis, zaxis );		
			vPosition.xyz 			= mul( RotationMatrix, vPosition.xyz ); //Do rotation	
			
			vPosition.xyz *= v.vInstanceRotationSize.w; //Scale
			vPosition.xyz += v.vInstanceOffset.xyz; //Position offset
			
			Out.vNormal = normalize( mul( RotationMatrix, v.vNormal ) );
			Out.vTangent = normalize( mul( RotationMatrix, v.vTangent.xyz ) );
			Out.vBitangent = normalize( cross( Out.vNormal, Out.vTangent ) * v.vTangent.w );
			
			Out.vPosition = vPosition;
			Out.vPos = Out.vPosition;
			Out.vPosition = mul( ViewProjectionMatrix, Out.vPosition );
			
			Out.vUV0 = v.vUV0;
			Out.vUV1 = v.vUV1;
			return Out;
		}
		
	]]
}

PixelShader =
{
	MainCode AsteroidPixelShader
		ConstantBuffers = { Common, TiledPointLight }
	[[
		float4 main( VS_OUTPUT In ) : PDX_COLOR
		{
			float4 vDiffuse = tex2D( DiffuseMap, In.vUV0 );
			
			float3 vPos = In.vPos.xyz / In.vPos.w;
		
			float3 vColor = vDiffuse.rgb;
			float3 vInNormal = normalize( In.vNormal );
			float4 vProperties = tex2D( SpecularMap, In.vUV0 );
			
			LightingProperties lightingProperties;
			
		#ifndef PDX_LEGACY_BLINN_PHONG
			float4 vNormalMap = tex2D( NormalMap, In.vUV0 );
			float3 vNormalSample =  UnpackRRxGNormal(vNormalMap);
			
			lightingProperties._Glossiness = vProperties.a;
		#else
			float3 vNormalSample = UnpackNormal( NormalMap, In.vUV0 );
			
			lightingProperties._SpecularColor = vec3(vProperties.a);
			lightingProperties._Glossiness = SPECULAR_WIDTH;
		#endif
		
			lightingProperties._NonLinearGlossiness = GetNonLinearGlossiness(lightingProperties._Glossiness);

			float3x3 TBN = Create3x3( normalize( In.vTangent ), normalize( In.vBitangent ), vInNormal );
			float3 vNormal = normalize(mul( vNormalSample, TBN ));
			
			float fShadowTerm = 1.0f;
		
			lightingProperties._WorldSpacePos = vPos;
			lightingProperties._ToCameraDir = normalize(vCamPos - vPos);
			lightingProperties._Normal = vNormal;
		#ifndef PDX_LEGACY_BLINN_PHONG
			float SpecRemapped = vProperties.g * vProperties.g * 0.4;
			float MetalnessRemapped = 1.0 - (1.0 - vProperties.b) * (1.0 - vProperties.b);
			lightingProperties._Diffuse = MetalnessToDiffuse(MetalnessRemapped, vColor);
			lightingProperties._SpecularColor = MetalnessToSpec(MetalnessRemapped, vColor, SpecRemapped);
		#else
			lightingProperties._Diffuse = vColor;
		#endif
			
			float3 diffuseLight = vec3(0.0);
			float3 specularLight = vec3(0.0);
			//CalculateSunLight(lightingProperties, fShadowTerm, diffuseLight, specularLight);
			CalculateSystemPointLight(lightingProperties, 1.0f, diffuseLight, specularLight);
			CalculatePointLights(lightingProperties, LightDataMap, LightIndexMap, diffuseLight, specularLight);

		#ifndef PDX_LEGACY_BLINN_PHONG
			float3 vEyeDir = normalize( vPos - vCamPos.xyz );
			float3 reflection = reflect( vEyeDir, vNormal );
			float MipmapIndex = GetEnvmapMipLevel(lightingProperties._Glossiness); 

			float3 reflectiveColor = texCUBElod( EnvironmentMap, float4(reflection, MipmapIndex) ).rgb * CubemapIntensity;
			specularLight += reflectiveColor * FresnelGlossy(lightingProperties._SpecularColor, -vEyeDir, lightingProperties._Normal, lightingProperties._Glossiness);
		#endif
			vColor = ComposeLight(lightingProperties, 1.0f, diffuseLight, specularLight);
				
			//float alpha = vDiffuse.a;
			return float4(vColor, 0);
		}	
	]]
}

BlendState BlendState
{
	BlendEnable = no
	WriteMask = "RED|GREEN|BLUE|ALPHA"
}

Effect Asteroid
{
	VertexShader = "AsteroidVertexShader"
	PixelShader = "AsteroidPixelShader"
}