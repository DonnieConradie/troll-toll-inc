shader_type canvas_item;

// This uniform is a value we can control from GDScript.
// 0.0 = fully revealed (original color).
// 1.0 = fully silhouetted (black, but preserves alpha).
uniform float silhouette_strength : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	// Get the original color and alpha of the current pixel from the texture.
	vec4 original_color = texture(TEXTURE, UV);
	
	// Define our silhouette color. It's pure black (0,0,0) but
	// it crucially uses the original pixel's alpha. This prevents
	// transparent areas from turning into solid black blocks.
	vec4 silhouette_color = vec4(0.0, 0.0, 0.0, original_color.a);
	
	// The mix() function blends between two colors.
	// When silhouette_strength is 1.0, the color will be silhouette_color.
	// When silhouette_strength is 0.0, the color will be original_color.
	COLOR = mix(original_color, silhouette_color, silhouette_strength);
}