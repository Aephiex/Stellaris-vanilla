
VertexStruct VS_INPUT
{
    float3 vPosition  : POSITION;
	float4 vColor	  : COLOR;
};

VertexStruct VS_INPUT2D
{
    float2 vPosition  : POSITION;
	float4 vColor	  : COLOR;
};

VertexStruct VS_OUTPUT
{
    float4  vPosition : PDX_POSITION;
 	float4  vColor	  : TEXCOORD1;
};


ConstantBuffer( Common, 0, 0 )
{
	float4x4 Transform;//			: register( c0 );
};


VertexShader =
{
	MainCode VertexShader
		ConstantBuffers = { Common }
	[[
		VS_OUTPUT main(const VS_INPUT v )
		{
		    VS_OUTPUT Out;
		    Out.vPosition = mul( Transform, float4( v.vPosition.xyz, 1.0f ) );	
			Out.vColor = v.vColor;
		    return Out;
		}
		
	]]
	
	MainCode VertexShader2D
		ConstantBuffers = { Common }
	[[
		VS_OUTPUT main(const VS_INPUT2D v )
		{
		    VS_OUTPUT Out;
		    Out.vPosition = mul( Transform, float4( v.vPosition.xy, 0.0, 1.0 ) );	
			Out.vColor = v.vColor;
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
	SourceBlend = "SRC_ALPHA"
	DestBlend = "INV_SRC_ALPHA"
	WriteMask = "RED|GREEN|BLUE"
}


Effect DebugLines
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
}

Effect DebugLines2D
{
	VertexShader = "VertexShader2D"
	PixelShader = "PixelShader"
}
