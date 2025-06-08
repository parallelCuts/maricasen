shader_type canvas_item;

uniform float amplitude : hint_range(0.0, 50.0) = 5.0;
uniform float frequency : hint_range(0.0, 10.0) = 5.0;
uniform float speed : hint_range(0.0, 10.0) = 1.0;

void fragment() {
    // Time-based horizontal offset
    float wave = sin(UV.y * frequency + TIME * speed) * (amplitude / 100.0);
    vec2 new_uv = UV + vec2(wave, 0.0);
    COLOR = texture(TEXTURE, new_uv) * texture(TEXTURE, UV).a;
}
