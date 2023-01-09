shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;

group_uniforms Base_Material;
group_uniforms Base_Material.Albedo;
uniform sampler2D texture_albedo : source_color,filter_linear_mipmap,repeat_enable;

group_uniforms Base_Material.Roughness;
uniform sampler2D texture_roughness : hint_roughness_r,filter_linear_mipmap,repeat_enable;

group_uniforms Base_Material.Specular;
uniform sampler2D texture_specular : source_color,filter_linear_mipmap,repeat_enable;

group_uniforms Base_Material.Normal;
uniform float normal_factor : hint_range(-16,16) = 0.5;
uniform sampler2D texture_normal : hint_roughness_normal,filter_linear_mipmap,repeat_enable;

group_uniforms Base_Material.UV;
uniform vec3 uv_scale = vec3(1.0);
uniform vec3 uv_offset = vec3(0.0);

void vertex() 
{
	// UV Calulation
	UV = UV * uv_scale.xy + uv_offset.xy;
}

void fragment() 
{
	// Define UVs
	vec2 base_uv = UV;
	
	// Define Albedo
	vec4 albedo_tex = texture(texture_albedo, base_uv);
	ALBEDO = albedo_tex.rgb;
	
	// Define Roughness
	float roughness_factor = texture(texture_roughness, base_uv).r;
	ROUGHNESS = roughness_factor;
	
	// Define Specular
	float specular_factor = texture(texture_specular, base_uv).r;
	SPECULAR = specular_factor;
	
	// Define Normals
	NORMAL_MAP = texture(texture_normal, base_uv).rgb;
	NORMAL_MAP_DEPTH = normal_factor;
}
