// NOTE: Shader automatically converted from Godot Engine 4.3.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_front, unshaded;

uniform vec4 albedo : source_color;
uniform float grow : hint_range(-16.0, 16.0, 0.001);

void vertex() {
	// Grow: Enabled
	// VERTEX += NORMAL * grow;
	VERTEX += normalize(VERTEX) * grow;
}

void fragment() {
	ALBEDO = albedo.rgb;
}
