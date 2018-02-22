Includes = {
	"constants.fxh"
	"standardfuncsgfx.fxh"
	"terra_incognita.fxh"
}

PixelShader =
{
	Samplers = 
	{		
		TerraIncognitaTexture = 
		{
			Index = 0;
			MagFilter = "Linear";
			MinFilter = "Linear";
			AddressU = "Clamp"
			AddressV = "Clamp"
		}
	}
}

BlendState BlendState
{
	BlendEnable = yes
	AlphaTest = no
	SourceBlend = "SRC_ALPHA"
	DestBlend = "INV_SRC_ALPHA"
	WriteMask = "RED|GREEN|BLUE"
}

DepthStencilState DepthStencilState
{
	DepthEnable = no
}

VertexStruct VS_INPUT
{
    float3 vPosition  : POSITION;
	float  vAccess : TEXCOORD0;
};

VertexStruct VS_OUTPUT
{
    float4  vPosition 	: PDX_POSITION;
	float2	vPos 		: TEXCOORD0;
	float	vAccess		: TEXCOORD1;
};

VertexShader =
{
	MainCode VertexShader
		ConstantBuffers = { Common }
	[[
		VS_OUTPUT main(const VS_INPUT v )
		{ 
			VS_OUTPUT Out;
			Out.vPos = v.vPosition.xz;
			Out.vPosition  	= mul( ViewProjectionMatrix, float4( v.vPosition, 1.0 ) );	
			Out.vAccess = v.vAccess;
			return Out;
		}
		
	]]
}

PixelShader =
{	
	MainCode PixelShader
	[[
		float4 main( VS_OUTPUT v ) : PDX_COLOR
		{
			float fMinAlpha = 0.05f;
			float fAlpha = 0.25f;
			float4 vHasAccess = float4( HSVtoRGB( float3( 3.25, 1.0, 1.5 ) ), fAlpha );
			float4 vNoAccess = float4( HSVtoRGB( float3( 0.1, 1.0, 0.9 ) ), fAlpha );
			float4 vColor = lerp( vNoAccess, vHasAccess, saturate( pow( v.vAccess, 15 ) ) );
			vColor = ApplyTerraIncognita( vColor, v.vPos, 5.f, TerraIncognitaTexture );
			vColor.a = lerp( fMinAlpha, fAlpha, CalcTerraIncognitaValue( v.vPos, TerraIncognitaTexture ) );
			return vColor;
		}
		
	]]
}

Effect Hyperlane
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
}
