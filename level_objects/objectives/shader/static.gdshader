shader_type spatial;

uniform float amount = 40.0;
uniform sampler2D albedo_texture : source_color;

void fragment() {
	vec2 uv = UV*0.05;
	float a = fract(sin(dot(vec2(UV.x*TIME,UV.y), vec2(12.9898, 78.233) * TIME)) * 438.5453) * 1.9;
	vec3 col = texture(albedo_texture, UV).rgb;
	col *= pow(a, amount);
	ALBEDO = col;
}