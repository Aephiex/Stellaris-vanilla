
PixelShader =
{
	Samplers =
	{	
		Diffuse =
		{
			Index = 0
			MagFilter = "Linear"
			MinFilter = "Linear"
			MipFilter = "Linear"
			AddressU = "Clamp"
			AddressV = "Wrap"
		}	
	}
}

VertexStruct VS_INPUT
{
    float2 	vPosition				: POSITION;
	float2 	vUV						: TEXCOORD0;
};

VertexStruct VS_OUTPUT
{
    float4 	vPosition				: PDX_POSITION;
	float2 	vUV						: TEXCOORD0;
};

ConstantBuffer( Beam, 0, 0 )
{
	float4x4	ViewProjectionMatrix;
	float3 		vCamPos;
	float		vBeamTextureOffset;
	float4 		vBeamColor;
	float3		vBeamStart;
	float 		vBeamWidth;
	float3		vBeamEnd;
	float		vBeamTextureTiling;
	float		vBeamAlpha;
	float		vFadeInStart;
	float		vFadeOutEnd;
	float 		vFadeInWidth;
	float 		vFadeOutWidth;
	float 		vBeamLength;
}

VertexShader =
{
	MainCode VertexShader
		ConstantBuffers = { Beam }
	[[
		VS_OUTPUT main( const VS_INPUT v )
		{			
			float3 Beam = vBeamEnd - vBeamStart;
			float3 Tangent = normalize( cross( Beam, vCamPos - vBeamStart ) );
						
			float4 Pos;
			Pos.xyz = vBeamStart + ( Tangent * vBeamWidth * v.vPosition.x ) + Beam * v.vPosition.y;
			Pos.w = 1.0f;
						
			VS_OUTPUT Out;			
			Out.vPosition = mul( ViewProjectionMatrix, Pos );
			Out.vUV = v.vUV;
			return Out;
		}
		
	]]
}

PixelShader =
{

	MainCode PixelShader
		ConstantBuffers = { Beam }
	[[
		float4 main( VS_OUTPUT In ) : PDX_COLOR
		{
			float2 vUV = In.vUV;
						
			//return float4( frac(vUV), 0.0f, 0.25f );

			float vDist = vUV.y * vBeamLength;
			float vInDivisor = clamp( vFadeInWidth, 0.0001, vFadeInWidth );
			float vOutDivisor = clamp( vFadeOutWidth, 0.0001, vFadeOutWidth );
			float vStartPart = ( vDist - vFadeInStart * vBeamLength ) / vInDivisor;
			float vEndPart = ( vFadeOutEnd * vBeamLength - vDist ) / vOutDivisor;
			float vFadeAlpha = saturate( vStartPart ) * saturate( vEndPart );

			vUV.y *= vBeamTextureTiling;
			vUV.y -= vBeamTextureOffset;

			float4 vColor = tex2D( Diffuse, vUV );
			vColor *= vBeamColor;
			vColor.a *= vBeamAlpha * vFadeAlpha;
			return vColor;
		}
	]]
}

BlendState BlendState
{
	BlendEnable = yes
	SourceBlend = "SRC_ALPHA"
	DestBlend = "ONE"
	WriteMask = "RED|GREEN|BLUE"
}

RasterizerState RasterizerState
{
	FillMode = "FILL_SOLID"
	CullMode = "CULL_NONE"
	#FrontCCW = no
}

DepthStencilState DepthStencilState
{
	DepthEnable = yes
	DepthWriteMask = "depth_write_zero"
}

Effect Beam
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
}