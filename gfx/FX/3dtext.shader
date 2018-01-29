Includes = {
	"constants.fxh"
	"standardfuncsgfx.fxh"
}
ConstantBuffer( CommonAlternative, 0, 0 )
{
	float4x4	ViewProjectionMatrix_Duplicate;
	float4x4	Transform;
	float3		vCameraPosition;
	float		vOverValue;
	float		vDownValue;
	float 		vSelectedValue;
	float 		vDisabledValue;
};

PixelShader =
{
	Samplers =
	{	
		Diffuse =
		{
			Index = 0
			MagFilter = "linear"
			MinFilter = "linear"
			AddressU = "Clamp"
			AddressV = "Clamp"
		}	
	}
}

VertexStruct VS_INPUT
{
    float3 	vPosition				: POSITION;
	float2 	vUV						: TEXCOORD0;
};

VertexStruct VS_OUTPUT
{
    float4 	vPosition				: PDX_POSITION;
	float2 	vUV						: TEXCOORD0;
	float3 	vPos					: TEXCOORD1;
};

VertexShader =
{
	MainCode VertexShader
		ConstantBuffers = { CommonAlternative }
	[[
		VS_OUTPUT main( const VS_INPUT v )
		{
			VS_OUTPUT Out;
					
			float4 vPosition = float4( v.vPosition.xyz, 1.0f );	
			
			Out.vPosition = mul( Transform, vPosition );
			
			Out.vPos = Out.vPosition.xyz;
			
			Out.vPosition = mul( ViewProjectionMatrix_Duplicate, Out.vPosition );
			
			Out.vUV = v.vUV;
			
			return Out;
		}
		
	]]
}

PixelShader =
{

	MainCode PixelShader
		ConstantBuffers = { CommonAlternative }
	[[
		float4 main( VS_OUTPUT In ) : PDX_COLOR
		{
			float vSharpness = 10000.f;
			
			float vAlpha = tex2D( Diffuse, In.vUV ).a;			
			float vDistance = sqrt( dot( In.vPos - vCameraPosition, In.vPos - vCameraPosition ) );			
			float vEpsilon = lerp( 0.01f, 0.5f, saturate( vDistance / vSharpness ) );			
			
			vAlpha = smoothstep( 0.5f - vEpsilon, 0.5f + vEpsilon, vAlpha );
			
			float4 vColor = float4( 1.0f, 1.0f, 1.0f, vAlpha );
			
			#ifdef BUTTON_STATES
				
				float3 vDefault 	= float3( 2.6f, 0.5f, 1.0f );
				float3 vOver 		= float3( 0.5f, 1.0f, 1.0f );
				float3 vSelected 	= float3( 1.0f, 0.0f, 1.0f );
				
				vDefault 		= HSVtoRGB( vDefault );
				vSelected 	= HSVtoRGB( vSelected );
				vOver 		= HSVtoRGB( vOver );
				
				vDefault 	= ToLinear( vDefault );
				vSelected 	= ToLinear( vSelected );
				vOver 		= ToLinear( vOver );
				
				vColor.rgb = vDefault;
				vColor.rgb = lerp( vColor.rgb, vSelected, vSelectedValue );
				vColor.rgb = lerp( vColor.rgb, vOver, vOverValue );

			    float Grey = dot( vDefault.rgb, float3( 0.212671f, 0.715160f, 0.072169f ) ); 
			    vColor.rgb = lerp( float3(Grey, Grey, Grey), vColor.rgb, vDisabledValue );				
			#endif
			
			return vColor;
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

RasterizerState RasterizerState
{
	FillMode = "FILL_SOLID"
	CullMode = "CULL_NONE"
}

DepthStencilState DepthStencilState
{
	DepthEnable = yes
	DepthWriteMask = "depth_write_zero"
}

Effect 3DText
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
}

Effect 3DTextButtonStates
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
	Defines = { "BUTTON_STATES" }
}