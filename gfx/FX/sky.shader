Includes = {
	"constants.fxh"
	"standardfuncsgfx.fxh"
	"color_lut.fxh"
}

PixelShader =
{
	Samplers = 
	{
		CubeMapTexture = 
		{
			Index = 0
			MagFilter = "Linear"
			MipFilter = "Linear"
			MinFilter = "Linear"
			AddressU = "Clamp"
			AddressV = "Clamp"
			Type = "Cube"
		}
		ColorCube =
		{
			Index = 1
			MagFilter = "Linear"
			MinFilter = "Linear"
			MipFilter = "None"
			AddressU = "Clamp"
			AddressV = "Clamp"
			MaxAnisotropy = 0
		}
	}
}

VertexStruct VS_INPUT
{
    float2 vPosition  		: POSITION;
};

VertexStruct VS_OUTPUT
{
    float4 vPosition 	: PDX_POSITION;
	float3 vPos			: TEXCOORD0;
};

ConstantBuffer( Common, 0, 0 )
{
	float4x4	InvViewProjMatrix;
	float4 		vCameraPos;
	float3		vHsvShift;
	float 		vIntel;
	float		vSkyTime;
};

VertexShader =
{
	MainCode VertexShader
		ConstantBuffers = { Common }
	[[
		VS_OUTPUT main(const VS_INPUT v )
		{
			VS_OUTPUT Out;

			Out.vPosition = float4( v.vPosition, 1.0f, 1.0f );

			//// Calculate rotation matrix from rotation direction
			//float3 vUp 				= normalize( float3( 0.0f, 1.0f, 0.0f ) );
			//float3 zaxis 			= normalize( float3( 0.1f, 0.3f, 0.2f ) ); //Dir
			//float3 xaxis 			= normalize( cross( vUp, zaxis ) );
			//float3 yaxis 			= normalize( cross( zaxis, xaxis ) );
			//float3x3 RotationMatrix = Create3x3( xaxis, yaxis, zaxis );

			float4 vPos = mul( InvViewProjMatrix, Out.vPosition );
			vPos.xyz /= vPos.w;

			Out.vPos 	= vPos.xyz;
			//Out.vPos 	= mul( RotationMatrix, vPos.xyz ); //Do rotation	
			//Out.vCameraPos = mul( RotationMatrix, vCameraPos.xyz ); //Do rotation

			return Out;
		}
		
	]]
}

PixelShader =
{
	MainCode PixelShader
		ConstantBuffers = { Common }
	[[
		//float3 ToLinear(float3 aGamma)
		//{
		//	return pow(aGamma, vec3(2.2));
		//}
		//
		//float3 ToGamma(float3 aLinear)
		//{
		//	return pow(aLinear, vec3(0.45));
		//}
		float4 main( VS_OUTPUT v ) : PDX_COLOR
		{			
			float3 vTexCoord = normalize( v.vPos - vCameraPos.xyz );
			//vTexCoord.z = -vTexCoord.z; //<-- This will mirror it
			
			#ifdef YCOCG
				float4 vColor2 = texCUBE( CubeMapTexture, vTexCoord );
				float scale = ( vColor2.z * ( 255.0 / 8.0 ) ) + 1.0;
				float Co = ( vColor2.x - ( 0.5 * 256.0 / 255.0 ) ) / scale;
				float Cg = ( vColor2.y - ( 0.5 * 256.0 / 255.0 ) ) / scale;
				float Y = vColor2.w;
				float R = Y + Co - Cg;
				float G = Y + Cg;
				float B = Y - Co - Cg;
				float3 vColor = ToLinear( float3(R,G,B) );
			#else
				float3 vColor = texCUBE( CubeMapTexture, vTexCoord ).rgb;
			#endif
			
			float3 vHSV = RGBtoHSV( vColor.rgb );
			float3 vShift = vHsvShift;
			const float HUE_MAX = 6.0f;			
			vShift.x *= HUE_MAX;
			#ifdef PDX_OPENGL
				vHSV.x = mod( HUE_MAX + vHSV.x + vShift.x, HUE_MAX );
			#else
				vHSV.x = fmod( HUE_MAX + vHSV.x + vShift.x, HUE_MAX );
			#endif
			vHSV.yz = saturate( vHSV.yz * ( vec2( 1.f ) + vShift.yz ) );
			vColor.rgb = HSVtoRGB( vHSV );
			
			vColor.rgb = SampleColorCube( vColor.rgb, ColorCube );			
			
		    float Grey = dot( vColor.rgb, float3( 0.212671f, 0.715160f, 0.072169f ) ); 
		    vColor.rgb = lerp( float3(Grey, Grey, Grey), vColor.rgb, vIntel );

			return float4( vColor, .0f );
		}
		
	]]
}


DepthStencilState DepthStencilState
{
	DepthEnable = yes
	DepthWriteMask = "DEPTH_WRITE_ZERO"
}

BlendState BlendState
{
	#WriteMask = "RED"
	BlendEnable = no
	AlphaTest = no
}

RasterizerState RasterizerState
{
	FillMode = "FILL_SOLID"
	CullMode = "CULL_BACK"
	FrontCCW = no
}

Effect Sky
{
	VertexShader = "VertexShader";
	PixelShader = "PixelShader";
}

Effect Sky_YCoCg
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
	Defines = { "YCOCG" }
}
