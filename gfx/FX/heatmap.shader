VertexStruct VS_INPUT
{
	float3  vPosition 	: POSITION;
	float  	vValue 		: TEXCOORD0;
};
VertexStruct VS_OUTPUT
{
	float4  vPosition 	: PDX_POSITION;
	float  	vValue 		: TEXCOORD0;
};

ConstantBuffer( 0, 0 )
{
	float4x4	ViewProjectionMatrix;
	float		vMinValue;
	float		vMaxValue;
	float		vAlpha;
}

VertexShader =
{
	MainCode VertexShader
	[[
		VS_OUTPUT main(const VS_INPUT v )
		{
			VS_OUTPUT Out;
			Out.vPosition  	= mul( ViewProjectionMatrix, float4( v.vPosition.xyz, 1.0f ) );
			Out.vValue = v.vValue;
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
			float vValue = ( ( v.vValue - vMinValue ) ) / ( vMaxValue - vMinValue );
			return float4( saturate( vec3( vValue ) ), 0.5f );
		}		
	]]
}

BlendState BlendState
{
	BlendEnable = yes
	AlphaTest = no
	SourceBlend = "SRC_ALPHA"
	DestBlend = "INV_SRC_ALPHA"
	#BlendOp = "blend_op_min"
	#BlendOpAlpha = "blend_op_max"
	#SourceAlpha = "zero"
	#DestAlpha = "one"
	WriteMask = "RED|GREEN|BLUE"
}

DepthStencilState DepthStencilState
{
	DepthEnable = yes
	#DepthWriteMask = "depth_write_zero"
}

RasterizerState RasterizerState
{
	FillMode = "FILL_SOLID"
	CullMode = "CULL_NONE"
	#FrontCCW = no
	
	#FillMode = "fill_wireframe"	
}

Effect heatmap
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
}