Includes = {
	"color_lut.fxh"
}

PixelShader =
{
	Samplers = 
	{
		DiffuseTexture = 
		{
			Index = 0;
			MagFilter = "Linear";
			MinFilter = "Linear";
			AddressU = "Clamp";
			AddressV = "Clamp";
		}
		ColorCube =
		{
			Index = 1
			MagFilter = "Linear"
			MinFilter = "Linear"
			MipFilter = "None"
			AddressU = "Clamp"
			AddressV = "Clamp"
			MaxAnisotropy = 0
		}	
	}
}

VertexStruct VS_INPUT
{
    float2 vPosition  		: POSITION;
	float2 vUV				: TEXCOORD0;
};

VertexStruct VS_OUTPUT
{
    float4 vPosition 	: PDX_POSITION;
	float2 vUV			: TEXCOORD0;
};

ConstantBuffer( Common, 0, 0 )
{
	float4x4 	ViewProjectionMatrix;
};

VertexShader =
{
	MainCode VertexShader
		ConstantBuffers = { Common }
	[[
		VS_OUTPUT main(const VS_INPUT v )
		{
			VS_OUTPUT Out;
			float4 vPos 	= float4( v.vPosition.x, v.vPosition.y, 0.0f, 1.0f );	
			Out.vPosition  	= mul( ViewProjectionMatrix, vPos );
			Out.vUV			= v.vUV;
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
			float4 vColor = tex2D( DiffuseTexture, v.vUV );

		#ifdef COLOR_LUT
			vColor.rgb = SampleColorCube( vColor.rgb, ColorCube );
		#endif
			
			return vColor;
		}
		
	]]
}


DepthStencilState DepthStencilState
{
	DepthEnable = no
}

BlendState BlendState
{
	BlendEnable = yes
	SourceBlend = "SRC_ALPHA"
	DestBlend = "INV_SRC_ALPHA"
	WriteMask = "RED|GREEN|BLUE"	
}

BlendState BlendStateAlphaBlendWriteAlpha
{
	BlendEnable = yes
	SourceBlend = "SRC_ALPHA"
	DestBlend = "INV_SRC_ALPHA"
	WriteMask = "RED|GREEN|BLUE|ALPHA"	
}

RasterizerState RasterizerState
{
	FillMode = "FILL_SOLID";
	CullMode = "CULL_BACK";
	FrontCCW = no
}

Effect Environment
{
	VertexShader = "VertexShader";
	PixelShader = "PixelShader";
	Defines = { "IS_ENVIRONMENT" }
}

Effect City
{
	VertexShader = "VertexShader";
	PixelShader = "PixelShader";
	Defines = { "IS_CITY" "COLOR_LUT" }
}

Effect Room
{
	VertexShader = "VertexShader";
	PixelShader = "PixelShader";
	Defines = { "IS_ROOM" }
}

Effect Character
{
	VertexShader = "VertexShader";
	PixelShader = "PixelShader";
	BlendState = BlendStateAlphaBlendWriteAlpha
	Defines = { "IS_CHARACTER" }
}