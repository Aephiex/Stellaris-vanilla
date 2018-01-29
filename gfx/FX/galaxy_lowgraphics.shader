ConstantBuffer( Galaxy, 1, 32 )
{
	float2 InvWindowSize;
};

PixelShader =
{
	Samplers =
	{
		MainScene =
		{
			Index = 0
			MagFilter = "Linear"
			MinFilter = "Linear"
			MipFilter = "None"
			AddressU = "Clamp"
			AddressV = "Clamp"
		}
	}
}

VertexStruct VS_INPUT
{
    int2 position	: POSITION;
};


VertexStruct VS_OUTPUT
{
    float4 position			: PDX_POSITION;
	float2 uv				: TEXCOORD0;
};



VertexShader =
{
	MainCode VertexShader
		ConstantBuffers = { Galaxy }
	[[
		VS_OUTPUT main( const VS_INPUT VertexIn )
		{
			VS_OUTPUT VertexOut;
			VertexOut.position = float4( VertexIn.position, 0.0f, 1.0f );
			VertexOut.uv = float2(VertexIn.position.x, FIX_FLIPPED_UV(VertexIn.position.y)) * 0.5 + 0.5;
			VertexOut.uv.y = 1.0f - VertexOut.uv.y;
		
		#ifdef PDX_DIRECTX_9 // Half pixel offset
			VertexOut.position.xy += float2( -InvWindowSize.x, InvWindowSize.y );
		#endif
		
			return VertexOut;
		}
	]]
}

PixelShader =
{
	MainCode PixelShader
	[[
		float4 main( VS_OUTPUT Input ) : PDX_COLOR
		{
			return tex2Dlod0( MainScene, Input.uv );
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
	AlphaTest = no
	# SourceBlend = "SRC_ALPHA"
	DestBlend = "INV_SRC_ALPHA"
}

RasterizerState RasterizerState
{
	FillMode = "FILL_SOLID"
	CullMode = "CULL_NONE"
	FrontCCW = no
}

Effect GalaxyRestore
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
}

