VertexStruct VS_INPUT
{
    float3 vPosition  : POSITION;
	float4 vColor	  : COLOR;
};

VertexStruct VS_OUTPUT
{
    float4 vPosition 	: PDX_POSITION;
	float4  vColor	  	: TEXCOORD1;
};

ConstantBuffer( Common, 0, 0 )
{
	float4x4 	ViewProjectionMatrix;
	float		vAlpha;
};


VertexShader =
{
	MainCode VertexShader
		ConstantBuffers = { Common }
	[[
		VS_OUTPUT main(const VS_INPUT v )
		{
			VS_OUTPUT Out;
			Out.vPosition  	= mul( ViewProjectionMatrix, float4( v.vPosition.rgb, 1.0f ) );	
			Out.vColor		= v.vColor;
			Out.vColor.a 	*= vAlpha;
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
			float4 OutColor = v.vColor;
			return OutColor;
		}
		
	]]
}

BlendState BlendState
{
	BlendEnable = yes
	AlphaTest = no
	SourceBlend = "SRC_ALPHA"
	DestBlend = "INV_SRC_ALPHA"
}

DepthStencilState DepthStencilNoZWrite
{
	DepthEnable = yes
	DepthWriteMask = "DEPTH_WRITE_ZERO"
}

Effect OrbitLines
{
	VertexShader = "VertexShader";
	PixelShader = "PixelShader";
	DepthStencilState = "DepthStencilNoZWrite";
}

Effect Lines
{
	VertexShader = "VertexShader";
	PixelShader = "PixelShader";
}
