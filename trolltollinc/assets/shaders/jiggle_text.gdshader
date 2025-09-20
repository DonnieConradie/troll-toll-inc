// res/shaders/jiggle_text.gdshader
shader_type canvas_item;

// Uniforms to control the effect from GDScript
uniform float jiggle_amount : hint_range(0.0, 5.0) = 1.5;
uniform float jiggle_speed : hint_range(0.0, 20.0) = 10.0;
// --- NEW: Controls the width of each "jumping" character block ---
uniform float character_width_factor : hint_range(0.0, 50.0) = 15.0;

void vertex() {
	// --- NEW LOGIC ---
	// 1. Calculate a unique, stable ID for each character based on its horizontal position.
	//    By flooring the U coordinate, we ensure all vertices within the same character column
	//    get the same base value for their sine wave.
	float char_id = floor(UV.x * character_width_factor);

	// 2. Calculate the vertical offset using this new character ID.
	//    This makes the entire character column jump up and down as a single unit.
	float y_offset = sin(TIME * jiggle_speed + char_id) * jiggle_amount;

	// 3. Apply the same offset to all vertices of the character.
	VERTEX.y += y_offset;
}