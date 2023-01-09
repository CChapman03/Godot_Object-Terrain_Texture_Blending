shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;

group_uniforms Triplanar_Material;
group_uniforms Triplanar_Material.Albedo;
uniform sampler2D texture_albedo : source_color,filter_linear_mipmap,repeat_enable;

group_uniforms Triplanar_Material.Roughness;
uniform sampler2D texture_roughness : hint_roughness_r,filter_linear_mipmap,repeat_enable;

group_uniforms Triplanar_Material.Specular;
uniform sampler2D texture_specular : source_color,filter_linear_mipmap,repeat_enable;

group_uniforms Triplanar_Material.Normal;
uniform sampler2D texture_normal : hint_roughness_normal,filter_linear_mipmap,repeat_enable;
uniform float normal_factor : hint_range(-16,16) = 0.5;

group_uniforms Triplanar_Material.UV;
varying vec3 uv_triplanar_pos;
uniform float uv_blend_sharpness;
varying vec3 uv_power_normal;
uniform vec3 uv_scale = vec3(0.25);
uniform vec3 uv_offset = vec3(0.5);


void vertex() 
{
	// Calculate Tangents
	TANGENT = vec3(0.0,0.0,-1.0) * abs(NORMAL.x);
	TANGENT += vec3(1.0,0.0,0.0) * abs(NORMAL.y);
	TANGENT += vec3(1.0,0.0,0.0) * abs(NORMAL.z);
	TANGENT = normalize(TANGENT);
	
	// Calculate Bi-Normals
	BINORMAL = vec3(0.0,1.0,0.0) * abs(NORMAL.x);
	BINORMAL += vec3(0.0,0.0,-1.0) * abs(NORMAL.y);
	BINORMAL += vec3(0.0,1.0,0.0) * abs(NORMAL.z);
	BINORMAL = normalize(BINORMAL);
	
	// Calculate UV triplanar parameters
	uv_power_normal = pow(abs(mat3(MODEL_MATRIX) * NORMAL), vec3(uv_blend_sharpness));
	uv_triplanar_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0f)).xyz * uv_scale + uv_offset;
	uv_power_normal /= dot(uv_power_normal,vec3(1.0));
	uv_triplanar_pos *= vec3(1.0,-1.0, 1.0);
}


vec4 triplanar_texture(sampler2D p_sampler,vec3 p_weights,vec3 p_triplanar_pos) 
{
	vec4 samp=vec4(0.0);
	samp += texture(p_sampler,p_triplanar_pos.xy) * p_weights.z;
	samp += texture(p_sampler,p_triplanar_pos.xz) * p_weights.y;
	samp += texture(p_sampler,p_triplanar_pos.zy * vec2(-1.0,1.0)) * p_weights.x;
	
	return samp;
}


void fragment() 
{
	// Define Albedo
	vec4 texture_albedo_triplanar = triplanar_texture(texture_albedo, uv_power_normal ,uv_triplanar_pos);
	ALBEDO = texture_albedo_triplanar.rgb;
	
	// Define Specular
	float specular_triplanar_factor = triplanar_texture(texture_specular, uv_power_normal, uv_triplanar_pos).r;
	METALLIC = 0.0;
	SPECULAR = specular_triplanar_factor;
	
	// Define Roughness
	float roughness_triplanar_factor = triplanar_texture(texture_roughness ,uv_power_normal, uv_triplanar_pos).r;
	ROUGHNESS = roughness_triplanar_factor;

	NORMAL_MAP = triplanar_texture(texture_normal, uv_power_normal, uv_triplanar_pos).rgb;
	NORMAL_MAP_DEPTH = normal_factor;
}
