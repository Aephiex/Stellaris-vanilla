# --------------------------------------------------------------
# A collection of constants that can be used to tweak the shaders
# To update: run "reloadfx all"
# --------------------------------------------------------------

Code
[[

// --------------------------------------------------------------
// ------------------    Light          -------------------------
// --------------------------------------------------------------
static const float3 SUN_DIFFUSE					= float3( 0.226f, 0.182f, 0.36f );


// --------------------------------------------------------------
// ------------------    HDR          	-------------------------
// --------------------------------------------------------------
static const float3 LUMINANCE_VECTOR  			= float3(0.2125f, 0.7154f, 0.0721f);


// --------------------------------------------------------------
// ------------------    Specular       -------------------------
// --------------------------------------------------------------
static const float SPECULAR_WIDTH 				= 15.0f;
static const float SPECULAR_MULTIPLIER			= 1.0f;
static const float MAP_SPECULAR_WIDTH 			= 15.0f;
static const float MAP_SPECULAR_MULTIPLIER		= 0.05f;


// --------------------------------------------------------------
// ------------------       ROADS       -------------------------
// --------------------------------------------------------------
static const float ROAD_TILE_FREQ				= 16.0f;
static const float ROAD_FADE_START				= 1.0f;
static const float ROAD_FADE_END				= 4.0f;

static const float ROAD_MAXIMAP_TILE_FREQ		= 30.f;
static const float ROAD_MAXIMAP_EXTRA_WIDTH		= 0.3f;

static const float ROAD_MINIMAP_TILE_FREQ		= 15.f;
static const float ROAD_MINIMAP_EXTRA_WIDTH		= 0.0f;


// --------------------------------------------------------------
// ------------------       COMBAT       ------------------------
// --------------------------------------------------------------
static const float COMBAT_OUTSIDE_BOUNDS_BRIGHTNESS	= 0.45f;
static const float COMBAT_INSIDE_BOUNDS_BRIGHTNESS	= 0.99f;
static const float COMBAT_BOUNDS_SHARPNESS 			= 0.1f;
static const float COMBAT_BOUNDS_BORDER_SHARPNESS	= 3.0f;


// --------------------------------------------------------------
// ------------------    WATER          -------------------------
// --------------------------------------------------------------
static const float 	WATER_TILE					= 1.8f;
static const float 	WATER_TIME_SCALE			= 0.03f;
static const float	WATER_FOG_START				= 16.5f;
static const float	WATER_FOG_END				= 19.7f;

static const float WATER_HEIGHT 				= 20.0f;
static const float WATER_HEIGHT_RECP 			= 1.0f / WATER_HEIGHT;
static const float WATER_HEIGHT_RECP_SQUARED 	= WATER_HEIGHT_RECP * WATER_HEIGHT_RECP;

static const float HEL_WATER_SCALE				= 1.2f;
static const float HEL_WATER_SPEED 				= 0.03f;
static const float HEL_WATER_GLOW_NOISE_SPEED	= 0.08f;
static const float HEL_WATER_GLOW_NOISE_SCALE   = 0.006f;


// --------------------------------------------------------------
// ------------------    SHADOW         -------------------------
// --------------------------------------------------------------
static const float  SHADOW_WEIGHT_TERRAIN    	= 1.0f;
static const float  SHADOW_WEIGHT_WATER   		= 1.0f;
static const float  SHADOW_WEIGHT_RIVER   		= 1.0f;
static const float  SHADOW_WEIGHT_TREE   		= 1.0f;
static const float  SHADOW_WEIGHT_ROAD   		= 1.0f;
static const float  SHADOW_WEIGHT_MESH   		= 1.0f;

// --------------------------------------------------------------
// -------------    RIM LIGHT (PDXMESH)   -----------------------
// --------------------------------------------------------------
static const float 	RIM_START 		= 0.6f;
static const float 	RIM_END 		= 1.0f;
static const float4 RIM_COLOR 		= float4( 0.3f, 0.6f, 0.8f, 0.0f );

]]
