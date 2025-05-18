shader_type canvas_item;

uniform float speed = 0.1;
uniform vec2 dir = vec2(0,0);

void fragment() {
	COLOR = texture(TEXTURE,mod(UV+dir*speed*TIME,1.0));
}
