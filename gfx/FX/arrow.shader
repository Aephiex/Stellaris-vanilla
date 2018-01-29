Includes = {
	"constants.fxh"
	"standardfuncsgfx.fxh"
}

PixelShader =
{
	Samplers =
	{
		DiffuseTexture =
		{
			Index = 0
			MagFilter = "Linear"
			MinFilter = "Linear"
			MipFilter = "Linear"
			AddressU = "Clamp"
			AddressV = "Clamp"
			MipMapLodBias = -0.6
		}
		NormalMap =
		{
			Index = 1
			MagFilter = "Linear"
			MinFilter = "Linear"
			MipFilter = "Linear"
			AddressU = "Clamp"
			AddressV = "Clamp"
		}
		SpecularMap =
		{
			Index = 2
			MagFilter = "Linear"
			MinFilter = "Linear"
			MipFilter = "Linear"
			AddressU = "Clamp"
			AddressV = "Clamp"
		}
		OverlayMap =
		{
			Index = 3
			MagFilter = "Linear"
			MinFilter = "Linear"
			MipFilter = "Linear"
			AddressU = "Wrap"
			AddressV = "Wrap"
		}
	}
}


VertexStruct VS_INPUT
{
    float3 vPosition  : POSITION;
	float2 vTexCoord  : TEXCOORD0;
};

VertexStruct VS_OUTPUT
{
    float4 vPosition : PDX_POSITION;
    float2 vTexCoord : TEXCOORD0;
	float3 vPos		 : TEXCOORD1;
};


ConstantBuffer( Arrow, 1, 32 )
{
	float4x4 ViewProj;
	float3 	vProgress_Move_Clip;
	float	vMaxLength;
};


VertexShader =
{
	MainCode VertexShader
		ConstantBuffers = { Arrow }
	[[
		VS_OUTPUT main(const VS_INPUT v )
		{
		 	VS_OUTPUT Out;
		
			float4 pos = float4( v.vPosition, 1.0f );
			pos.y += 2.0f;
			Out.vPos = pos.xyz;
		   	Out.vPosition  = mul( ViewProj, pos );	
			Out.vTexCoord = v.vTexCoord;
		
			return Out;
		}
	]]
}

PixelShader =
{
	MainCode PixelShader
		ConstantBuffers = { Common, Arrow }
	[[
		float4 main( VS_OUTPUT v ) : PDX_COLOR
		{
		 	clip( vProgress_Move_Clip.x - v.vTexCoord.y );
			clip( v.vTexCoord.y - vProgress_Move_Clip.z );

			float vTiling = 12.0f;
			float nNumTiles = floor( vMaxLength / vTiling );
			float vOffset = ( vMaxLength - ( vTiling * nNumTiles ) ) / vTiling;
			float2 vUV = v.vTexCoord.yx;
			vUV.x /= vTiling;
			vUV.x = vUV.x + 1.f - vOffset;

			float vTile = vUV.x;
			vUV.x = mod( vUV.x, 0.5 );

			if( vTile >= nNumTiles + 0.5f )
			{
				vUV.x += 0.5f;
			}
			else if( frac( vTile ) > 0.5f )
			{
				vUV.x = 0.5f - vUV.x;
			}
				
			//return float4( vUV.x, 0, 0, 1 );

			float4 OutColor = tex2D( DiffuseTexture, vUV );
			
			//Calculate Specular
			float4 Mask = tex2D( SpecularMap, vUV );
			
			float vOverlayValue = saturate(Mask.a - OutColor.a);
			float2 vOverlayUV = v.vTexCoord.xy;
			vOverlayUV.y *= 0.1;									// tiling 
			vOverlayUV.y -= HdrRange_Time_ClipHeight.y * 0.1f;		// Speed
			float vMipBias = -1.0f;
			float4 vOverlay = tex2Dbias( OverlayMap, float4( vOverlayUV.yx, 0, vMipBias ) );
			OutColor = lerp( OutColor, vOverlay, vOverlayValue );
			
			OutColor.a *= saturate( ( v.vTexCoord.y - vProgress_Move_Clip.z ) * 0.5f );
			//OutColor.a *= 2.0;
			return float4( OutColor.rgb, OutColor.a );
		}
	]]
}


BlendState BlendState
{
	BlendEnable = yes
	SourceBlend = "SRC_ALPHA"
	DestBlend = "INV_SRC_ALPHA"
	WriteMask = "RED|GREEN|BLUE"
}

DepthStencilState DepthStencilState
{
	DepthEnable = yes
	DepthWriteMask = "DEPTH_WRITE_ZERO"
}

RasterizerState RasterizerState
{
	CullMode = "CULL_NONE"
}

Effect ArrowEffect
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
}

