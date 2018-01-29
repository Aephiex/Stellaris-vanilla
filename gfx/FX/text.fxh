
VertexStruct VS_DEFAULT_TEXT_INPUT
{
	float4	vPosition	: POSITION;
	float2	vTexCoord	: TEXCOORD0;
	float4	vColor		: COLOR;
};

VertexStruct VS_DEFAULT_TEXT_OUTPUT
{
	float4	vPosition	: PDX_POSITION;
	float2	vTexCoord	: TEXCOORD0;
	float4	vColor		: TEXCOORD1;
};


ConstantBuffer( TextVertex, 1, 1 )		# Default vertex constants
{
	float4x4	_TextMatrix_;
	float4		_TextModColor_;
};

ConstantBuffer( TextPixel, 0, 0 )		# Default pixel constants
{
	float4		_TextColorAdd_;
};


Code
	ConstantBuffers = { TextVertex }
[[
	VS_DEFAULT_TEXT_OUTPUT DefaultTextVertexShader( VS_DEFAULT_TEXT_INPUT v )
	{
		VS_DEFAULT_TEXT_OUTPUT Out;

		Out.vPosition  	= mul( _TextMatrix_, v.vPosition );
		Out.vTexCoord  	= v.vTexCoord;
		Out.vColor		= v.vColor * _TextModColor_;

		return Out;
	}
]]


Code
	ConstantBuffers = { TextPixel }
[[
	float4 DefaultFontTextureSample( in sampler2D _FontTexture_, float2	vTexCoord )
	{
	    float4 OutColor = tex2D( _FontTexture_, vTexCoord );
		OutColor.rgb += _TextColorAdd_.rgb;
		return OutColor;
	}

	float4 DefaultTextPixelShader( VS_DEFAULT_TEXT_OUTPUT v, in sampler2D _FontTexture_ )
	{
	    float4 OutColor = DefaultFontTextureSample( _FontTexture_, v.vTexCoord );
		OutColor *= v.vColor;
	    return OutColor;
	}
]]
