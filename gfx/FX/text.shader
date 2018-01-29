Includes = {
	"text.fxh"
}


PixelShader =
{
	Samplers =
	{
		SimpleTexture =
		{
			Index = 0
			MagFilter = "Linear"
			MinFilter = "Linear"
			MipFilter = "Linear"
			AddressU = "Wrap"
			AddressV = "Wrap"
		}
	}
}


VertexShader =
{
	MainCode VertexShaderText
		ConstantBuffers = { TextVertex }
	[[
		VS_DEFAULT_TEXT_OUTPUT main( VS_DEFAULT_TEXT_INPUT v )
		{
			return DefaultTextVertexShader( v );
		}
	]]
}

PixelShader =
{
	MainCode PixelShaderText
		ConstantBuffers = { TextPixel }
	[[
		float4 main( VS_DEFAULT_TEXT_OUTPUT v ) : PDX_COLOR
		{
			return DefaultTextPixelShader( v, SimpleTexture );
		}
	]]
}


BlendState BlendState
{
	BlendEnable = yes
	AlphaTest = no
	SourceBlend = "SRC_ALPHA"
	DestBlend = "INV_SRC_ALPHA"
	BlendOpAlpha = blend_op_max
}

BlendState BlendState3D
{
	BlendEnable = yes
	SourceBlend = "SRC_ALPHA"
	DestBlend = "INV_SRC_ALPHA"
	WriteMask = "RED|GREEN|BLUE"
}


Effect Text
{
	VertexShader = "VertexShaderText"
	PixelShader = "PixelShaderText"
}

Effect Text3D
{
	VertexShader = "VertexShaderText"
	PixelShader = "PixelShaderText"
	BlendState = "BlendState3D"
}
