shader_type spatial;

uniform sampler2D albedo_texture : source_color;
uniform float layers = 1;
uniform vec2 motion = vec2(0,0);

void fragment() {
	vec2 uv = UV*layers;
	float layer = floor(UV.y*layers);
	float t = TIME*(1.0-float(int(layer)%2==0)*2.0);
	vec4 text = texture(albedo_texture, uv+motion*t);
	ALBEDO = text.rgb;
	ALPHA = text.a;
}
