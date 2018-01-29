Includes = {
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
			AddressU = "Wrap"
			AddressV = "Wrap"
		}
	}
}


VertexStruct VS_INPUT
{
    float4 vPosition  : POSITION;
};

VertexStruct VS_OUTPUT
{
    float4  vPosition : PDX_POSITION;
};

ConstantBuffer( Common, 0, 0 )
{
	float4x4 Mat;
	float4 vColor;
};



VertexShader =
{
	MainCode VertexShaderSimpleDebug
		ConstantBuffers = { Common }
	[[
		VS_OUTPUT main(const VS_INPUT v )
		{
		    VS_OUTPUT Out;
		    Out.vPosition  	= mul( Mat, v.vPosition );
		
		    return Out;
		}
		
		
	]]
}

PixelShader =
{
	MainCode PixelShaderSimpleDebug
		ConstantBuffers = { Common }
	[[
		float4 main( VS_OUTPUT v ) : PDX_COLOR
		{
		    return vColor;
		}
		
	]]
}


BlendState BlendState
{
	BlendEnable = no
}


Effect SimpleDebug
{
	VertexShader = "VertexShaderSimpleDebug"
	PixelShader = "PixelShaderSimpleDebug"
}

