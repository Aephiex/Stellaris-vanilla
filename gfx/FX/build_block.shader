VertexStruct VS_INPUT
{
	float3  vPosition 	: POSITION;
	float  	vRadius 	: TEXCOORD0;
};
VertexStruct VS_OUTPUT
{
	float4  vPosition 	: PDX_POSITION;
	float  	vRadius 	: TEXCOORD0;
};

ConstantBuffer( Common, 0, 0 )
{
	float4x4	ViewProjectionMatrix;
	float3 		vCamPos;
	float3 		vCamRightDir;
	float3 		vCamLookAtDir;
	float3 		vCamUpDir;
	float3 		HdrRange_Time_ClipHeight;
}

VertexShader =
{
	MainCode VertexShader
		ConstantBuffers = { Common }
	[[
		VS_OUTPUT main(const VS_INPUT v )
		{
			VS_OUTPUT Out;
			float3 vPos = float3( v.vPosition.x, 0.f, v.vPosition.z );
			float3 vToCamera = vCamPos - vPos;
			vPos -= vToCamera * v.vPosition.y * 0.005f;
			Out.vPosition  	= mul( ViewProjectionMatrix, float4( vPos.x, vPos.y, vPos.z, 1.0f ) );
			Out.vRadius = v.vRadius;
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
			return float4( 0.5f, 0.f, 0.f, 0.1f );
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
	WriteMask = "RED|GREEN|BLUE|ALPHA"
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
	FrontCCW = no
	
	#FillMode = "fill_wireframe"	
}

Effect Blocker
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
}