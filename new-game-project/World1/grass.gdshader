shader_type canvas_item;

// Base wind strength and speed
uniform float strength           = 1.5;
uniform float base_speed         = 1.0;
uniform float frequency          = 2.0;

// Size of each grass tile in pixels
uniform float tile_width         = 32.0;
uniform float tile_height        = 32.0;

// Wind gust settings
uniform float gust_strength      = 2.0;
uniform float gust_speed         = 0.5;

// Per‐tile phase variation scale
uniform float phase_offset_scale = 2.0;

void vertex() {
    float gust = sin(TIME * gust_speed) * 0.5 + 0.5;
    gust = gust * gust;
    float total_strength = strength + gust * gust_strength;

    float local_x = fract(VERTEX.x / tile_width) * tile_width;
    float phase_offset = local_x * phase_offset_scale;

    float phase = (VERTEX.x + TIME * base_speed + phase_offset) * frequency;

    float local_y = fract(VERTEX.y / tile_height) * tile_height;

    // ✅ Fix: Sway increases from bottom to top
    float falloff = clamp(local_y / tile_height, 0.0, 1.0);

    VERTEX.x += sin(phase) * total_strength * falloff;
}
