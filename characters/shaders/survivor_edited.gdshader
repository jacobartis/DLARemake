/*
This shader is under MIT license. Feel free to use, improve and
change this shader according to your needs and consider sharing
the modified result to godotshaders.com.
*/

shader_type canvas_item;

uniform float colors : hint_range(1.0, 16.0);
uniform float dither : hint_range(0.0, 1.0);

uniform sampler2D u_dither_tex: repeat_enable;

uniform int u_dither_size;

vec3 colour_redo(vec3 color, vec2 uv, vec2 pix_size){
	vec3 new_col = vec3(1,1,1);
	float a = floor(mod(uv.x / pix_size.x, 2.0));
	float b = floor(mod(uv.y / pix_size.y, 2.0));	
	float c = mod(a + b, 2.0);
	
	new_col.r = (round(color.r * colors + dither) / colors) * c;
	new_col.g = (round(color.g * colors + dither) / colors) * c;
	new_col.b = (round(color.b * colors + dither) / colors) * c;
	c = 1.0 - c;
	new_col.r += (round(color.r * colors - dither) / colors) * c;
	new_col.g += (round(color.g * colors - dither) / colors) * c;
	new_col.b += (round(color.b * colors - dither) / colors) * c;
	return new_col;
}

void fragment()
{
	// sample the screen texture at the desired output resolution (according to u_dither_size)
	// this will effectively pixelate the resulting output
	vec2 screen_size = vec2(textureSize(TEXTURE, 0)) / float(u_dither_size);
	vec2 screen_sample_uv = floor(UV * screen_size) / screen_size;
	vec3 screen_col = texture(TEXTURE, screen_sample_uv).rgb;

	// calculate pixel luminosity (https://stackoverflow.com/questions/596216/formula-to-determine-brightness-of-rgb-color)
	float lum = (screen_col.r * 0.299) + (screen_col.g * 0.587) + (screen_col.b * 0.114);

	// map the dither texture onto the screen. there are better ways of doing this that makes the dither pattern 'stick'
	// with objects in the 3D world, instead of being mapped onto the screen. see lucas pope's details posts on how he
	// achieved this in Obra Dinn: https://forums.tigsource.com/index.php?topic=40832.msg1363742#msg1363742
	ivec2 noise_size = textureSize(u_dither_tex, 0);
	vec2 inv_noise_size = vec2(1.0 / float(noise_size.x), 1.0 / float(noise_size.y));
	vec2 size = vec2(10.0,10.0);
	vec2 noise_uv = UV * inv_noise_size * vec2(float(screen_size.x), float(screen_size.y));
	float threshold = texture(u_dither_tex, noise_uv).r;
	// adjust the dither slightly so min and max aren't quite at 0.0 and 1.0
	// otherwise we wouldn't get fullly dark and fully light dither patterns at lum 0.0 and 1.0
	threshold = threshold * 0.99 + 0.005;

	// the lower lum_scaled is, the fewer pixels will be below the dither threshold, and thus will use the lower bound colour,
	// and vice-versa
	vec3 dith_text = texture(TEXTURE,UV).rgb*texture(u_dither_tex, noise_uv).rgb;
	vec3 display = colour_redo(dith_text,UV,TEXTURE_PIXEL_SIZE);
	
	//vec3 final_col = texture(u_color_tex, vec2(1.0, 1.0)).rgb;
	
	// return the final colour!
	COLOR.rgb = display;
}