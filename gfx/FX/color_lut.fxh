PixelShader = 
{
	Code
	[[
	float3 SampleColorCube( float3 aColor, in sampler2D ColorCubeSampler )
	{	
		float ColorCubeSize = 32.0;
		float scale = (ColorCubeSize - 1.0) / ColorCubeSize;
		float offset = 0.5 / ColorCubeSize;
		
		float x = ((scale * aColor.r + offset) / ColorCubeSize);
		float y = scale * aColor.g + offset;
		
		float zFloor = floor((scale * aColor.b + offset) * ColorCubeSize);
		float xOffset1 = zFloor / ColorCubeSize;
		float xOffset2 = min(ColorCubeSize - 1.0, zFloor + 1.0) / ColorCubeSize;
		
		float3 color1 = tex2D( ColorCubeSampler, float2(x + xOffset1, y) ).rgb;
		float3 color2 = tex2D( ColorCubeSampler, float2(x + xOffset2, y) ).rgb;
		
		float3 color = lerp(color1, color2, scale * aColor.b * ColorCubeSize - zFloor );
			
		return color;
	}
	]]
}
