shader_type canvas_item;
render_mode unshaded;

uniform sampler2D viewport_tex;
uniform float time;
uniform vec2 resolution = vec2(1920.0, 1080.0);

// Adjustable effect strength
uniform float chroma_strength = 1.5;
uniform float vignette_strength = 0.3;
uniform float bloom_strength = 0.2;
uniform float noise_strength = 0.03;


float random(vec2 uv) {
    return fract(sin(dot(uv.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

vec3 apply_chromatic_aberration(vec2 uv) {
    float offset = 0.0015 * chroma_strength;
    float r = texture(viewport_tex, uv + vec2(offset, 0.0)).r;
    float g = texture(viewport_tex, uv).g;
    float b = texture(viewport_tex, uv - vec2(offset, 0.0)).b;
    return vec3(r, g, b);
}

vec3 apply_bloom(vec2 uv) {
    float blur_size = 2.0 / resolution.x;
    vec3 color = vec3(0.0);
    for (int x = -2; x <= 2; x++) {
        for (int y = -2; y <= 2; y++) {
            vec2 off = vec2(float(x), float(y)) * blur_size;
            vec3 sample = texture(viewport_tex, uv + off).rgb;
            float bright = max(max(sample.r, sample.g), sample.b);
            color += sample * smoothstep(0.7, 1.0, bright);
        }
    }
    return color / 25.0;
}

float apply_vignette(vec2 uv) {
    vec2 pos = uv - 0.5;
    float dist = length(pos);
    float v = smoothstep(0.8, 0.5, dist);
    return mix(1.0, v, vignette_strength);
}

void fragment() {
    vec2 uv = UV;

    // — Base color + chromatic aberration
    vec3 color = apply_chromatic_aberration(uv);

    // — Bloom
    vec3 bloom = apply_bloom(uv);
    color += bloom * bloom_strength;

    // — Grain / noise
    float grain = random(uv + time) * noise_strength;
    color += grain;

    // — Vignette (early)
    color *= apply_vignette(uv);
    float flicker = 0.95 + 0.05 * sin(time * 4.0);
    float v2 = apply_vignette(uv);
    color *= mix(1.0, v2, vignette_strength * 0.6);
    color *= flicker;

    // — Mild tone curve
    color = pow(color, vec3(0.95));

    // — Soft‐clamp highlights
    vec3 soft_clamp = color / (color + vec3(0.8));
    float intensity = dot(color, vec3(0.2126, 0.7152, 0.0722));
    float blend    = smoothstep(1.0, 2.5, intensity);
    color = mix(color, soft_clamp, blend);

    COLOR = vec4(color, 1.0);
}
