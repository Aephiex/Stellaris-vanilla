Includes = {
	"constants.fxh"
}

PixelShader =
{
	Samplers =
	{
		Source =
		{
			Index = 0
			MagFilter = "Linear"
			MinFilter = "Linear"
			MipFilter = "Linear"
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
    float4 position	: PDX_POSITION;
	float2 uv		: TEXCOORD0;
};


ConstantBuffer( Common, 0, 0 )
{
	float2 InvSize;
};


VertexShader =
{
	MainCode VertexShader
		ConstantBuffers = { Common }
	[[
		VS_OUTPUT main( const VS_INPUT VertexIn )
		{
			VS_OUTPUT VertexOut;
			VertexOut.position = float4( VertexIn.position, 0.0, 1.0 );
			
			VertexOut.uv = float2(VertexIn.position.x, FIX_FLIPPED_UV(VertexIn.position.y)) * 0.5 + 0.5;
			VertexOut.uv.y = 1.0 - VertexOut.uv.y;
			
		#ifdef PDX_DIRECTX_9 // Half pixel offset
			VertexOut.position.xy += float2( -InvSize.x, InvSize.y );
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
			return tex2Dlod0( Source, Input.uv );
		}
	]]
}

DepthStencilState DepthStencilState
{
	DepthEnable = no
	DepthWriteMask = "DEPTH_WRITE_ZERO"
}

BlendState BlendState
{
	BlendEnable = no
}


Effect blit
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
}

