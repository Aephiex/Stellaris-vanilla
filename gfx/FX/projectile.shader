Includes = {
	"constants.fxh"
	"standardfuncsgfx.fxh"
}

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
    float4 	vPosition				: POSITION;
	float2 	vUV						: TEXCOORD0;
	float4 	vColor	  				: TEXCOORD1;
	float3	vBeamDir				: TEXCOORD2
	float 	vTime					: TEXCOORD3;
	float 	vLength					: TEXCOORD4;
	float2 	vTextureTilingAndSpeed	: TEXCOORD5;
};

VertexStruct VS_OUTPUT
{
    float4 	vPosition				: PDX_POSITION;
	float2 	vUV						: TEXCOORD0;
	float4  vColor	  				: TEXCOORD1;
	float 	vTime					: TEXCOORD2;
	float 	vLength					: TEXCOORD3;
	float2 	vTextureTilingAndSpeed	: TEXCOORD4;
};

VertexShader =
{
	MainCode VertexShader
		ConstantBuffers = { Common }
	[[
		VS_OUTPUT main( const VS_INPUT v )
		{
			VS_OUTPUT Out;
					
			float4 vPosition = float4( v.vPosition.xyz, 1.0f );	
			
			float3 vUp = cross( v.vBeamDir, ( vCamPos - v.vPosition.xyz ) );
			vPosition.xyz += v.vPosition.w * normalize( vUp );
			Out.vPosition = mul( ViewProjectionMatrix, vPosition );
			
			Out.vUV = v.vUV;
			Out.vTime = v.vTime;
			Out.vLength = v.vLength;
			Out.vTextureTilingAndSpeed = v.vTextureTilingAndSpeed;
			Out.vColor = v.vColor;
			
			return Out;
		}
		
	]]
}

PixelShader =
{

	MainCode PixelShaderLaser
	[[
		float4 main( VS_OUTPUT In ) : PDX_COLOR
		{
			float vTextureTiling = In.vTextureTilingAndSpeed.x;
			float vAnimationSpeed = In.vTextureTilingAndSpeed.y;
		
			float2 UV = In.vUV.xy;
			UV.y = -UV.y * ( In.vLength / vTextureTiling ) + In.vTime * vAnimationSpeed;
			//return float4( UV.x, 1.f+mod( UV.y, 1.0f ), 0.f, 1.0f );
			float4 vColor = tex2D( Diffuse, UV.xy );
			vColor *= In.vColor;
						
			//Fade in
			vColor.a *= saturate( ( 1.0f - In.vUV.y ) * In.vLength / 15.0f );
			
			//Fade out
			vColor.a *= pow( saturate( In.vUV.y * In.vLength * 2.f ), 2 );
			
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
	FrontCCW = no
}

DepthStencilState DepthStencilState
{
	DepthEnable = yes
	DepthWriteMask = "depth_write_zero"
}

Effect Laser
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShaderLaser"
}