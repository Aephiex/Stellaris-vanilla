
PixelShader =
{
	Samplers =
	{
		FrameTexture =
		{
			Index = 0
			MagFilter = "linear"
			MinFilter = "linear"
			MipFilter = "linear"
			AddressU = "Clamp"
			AddressV = "Clamp"
		}
		MaskingTexture =
		{
			Index = 1
			MagFilter = "linear"
			MinFilter = "linear"
			MipFilter = "linear"
			AddressU = "Clamp"
			AddressV = "Clamp"
		}
		SymbolTexture =
		{
			Index = 2
			MagFilter = "linear"
			MinFilter = "linear"
			MipFilter = "linear"
			AddressU = "Clamp"
			AddressV = "Clamp"
		}
		BackgroundTexture =
		{
			Index = 3
			MagFilter = "linear"
			MinFilter = "linear"
			MipFilter = "linear"
			AddressU = "Clamp"
			AddressV = "Clamp"
		}

	}
}

VertexStruct VS_INPUT
{
	float3 vPosition  : POSITION;
	float2 vTexCoord  : TEXCOORD0;
};

VertexStruct VS_OUTPUT
{
	float4  vPosition : PDX_POSITION;
	float2  vTexCoord : TEXCOORD0;
	float2	vFullTexCoord : TEXCOORD1;
};

ConstantBuffer( Common, 0, 0 )
{
	float4x4 WorldViewProjectionMatrix;	
	float4 ModulateColor;
	float2 Offset;
	float2 NextOffset;
	float Time;
	float AnimationTime;
	float2 SymbolPos;
	float4 BackgroundColor[4]; 
	float2 SymbolSize;
	float2 BGPos;
	float2 BGSize;
};

VertexShader =
{
	MainCode VertexShader
		ConstantBuffers = { Common }
	[[
		VS_OUTPUT main(const VS_INPUT v )
		{
		    VS_OUTPUT Out;
		    Out.vPosition  = mul( WorldViewProjectionMatrix, float4( v.vPosition.xyz, 1 ) );
			
		    Out.vTexCoord = v.vTexCoord;
			Out.vTexCoord += Offset;
			
			Out.vFullTexCoord = saturate( v.vTexCoord * 1000.f );
			
		    return Out;
		}
	]]
}

PixelShader =
{
	Code
	[[
		float4 GetFlagColor( float2 vUV )
		{
			float2 vBGUV = ( vUV - BGPos ) / BGSize;
			float4 vBG = tex2D( BackgroundTexture, vBGUV );
			
			float4 vColor = float4( 0, 0, 0, 1 );
			vColor += BackgroundColor[0] * vBG.r;
			vColor += BackgroundColor[1] * vBG.g;
			vColor += BackgroundColor[2] * vBG.b;
			vColor = saturate( vColor );
			//vColor += BackgroundColor[3] * vBG.a;
			float2 vSymbolUV = ( vUV - SymbolPos ) / SymbolSize;
			if( vSymbolUV.x >= 0.f && vSymbolUV.x <= 1.f && vSymbolUV.y >= 0.f && vSymbolUV.y <= 1.f )
			{
				float4 vSymbol = tex2D( SymbolTexture, vSymbolUV );
				vColor.rgb = lerp( vColor.rgb, vSymbol.rgb, vSymbol.a );
			}
			vColor.a = saturate( vColor.a );
			vColor.a *= tex2D( MaskingTexture, vUV ).a;
			return vColor;
		}
		
		float4 AddFrame( float4 vColor, float2 vUV )
		{
			float4 FrameColor = tex2D( FrameTexture, vUV ) * ModulateColor;
			
			vColor.rgb = lerp( vColor.rgb * vColor.a, FrameColor.rgb, FrameColor.a );
			vColor.a = max( vColor.a, FrameColor.a );
			return vColor;
		}
	]]
	
	MainCode PixelShaderUp
		ConstantBuffers = { Common }
	[[
		float4 main( VS_OUTPUT v ) : PDX_COLOR
		{
			//float2 vUV = ( v.vFullTexCoord - BGPos.xy ) / BGSize;
			//return mod( float4( 1+vUV.x, 1+vUV.y, 0.f, 1.f ), 1.00001f );
			float4 vColor = GetFlagColor( v.vFullTexCoord );
			vColor = AddFrame( vColor, v.vTexCoord );
			
			return vColor;
		}
	]]

	MainCode PixelShaderDown
		ConstantBuffers = { Common }
	[[
		float4 main( VS_OUTPUT v ) : PDX_COLOR
		{
		    float4 vColor = GetFlagColor( v.vFullTexCoord );
			vColor = AddFrame( vColor, v.vTexCoord );
			
			float vTime = 0.9 - saturate( (Time - AnimationTime) * 16 );
			vTime *= vTime;
			vTime = 0.9*0.9 - vTime;
		    float4 MixColor = float4( 0.15, 0.15, 0.15, 0 ) * vTime;
		    vColor.rgb -= ( 0.5 + vColor.rgb ) * MixColor.rgb;
			
			return vColor;
		}
	]]

	MainCode PixelShaderDisable
		ConstantBuffers = { Common }
	[[
		float4 main( VS_OUTPUT v ) : PDX_COLOR
		{
		    float4 vColor = GetFlagColor( v.vFullTexCoord );
			vColor = AddFrame( vColor, v.vTexCoord );
			
		    float Grey = dot( vColor.rgb, float3( 0.212671f, 0.715160f, 0.072169f ) ); 
		    vColor.rgb = float3(Grey, Grey, Grey);
			
			vColor *= ModulateColor;
		    return vColor;
		}	
	]]

	MainCode PixelShaderOver
		ConstantBuffers = { Common }
	[[
		float4 main( VS_OUTPUT v ) : PDX_COLOR
		{
		    float4 vColor = GetFlagColor( v.vFullTexCoord );
			vColor = AddFrame( vColor, v.vTexCoord );
			
			float vTime = 0.9 - saturate( (Time - AnimationTime) * 4 );
			vTime *= vTime;
			vTime = 0.9*0.9 - vTime;
		    float4 MixColor = float4( 0.15, 0.15, 0.15, 0 ) * vTime;
		    vColor.rgb += ( 0.5 + vColor.rgb ) * MixColor.rgb;
			
			return vColor;
		}
	]]
}


BlendState BlendState
{
	BlendEnable = yes
	SourceBlend = "src_alpha"
	DestBlend = "inv_src_alpha"
}


Effect Up
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShaderUp"
}

Effect Down
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShaderDown"
}

Effect Disable
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShaderDisable"
}

Effect Over
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShaderOver"
}
