shader_type spatial;

uniform float amount = 40.0;
uniform sampler2D albedo_texture : source_color;
uniform vec2 motion = vec2(0,0);

void fragment() {
	vec2 uv = UV*0.05;
	float a = fract(sin(dot(vec2(UV.x*TIME,UV.y), vec2(12.9898, 78.233) * TIME)) * 438.5453) * 1.9;
	vec3 col = texture(albedo_texture, UV+motion*TIME).rgb;
	col *= pow(a, amount);
	ALBEDO = col;
}