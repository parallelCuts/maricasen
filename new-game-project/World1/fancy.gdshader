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
    // Slight offsets per channel
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
            vec2 offset = vec2(float(x), float(y)) * blur_size;
            vec3 sample = texture(viewport_tex, uv + offset).rgb;
            float brightness = max(max(sample.r, sample.g), sample.b);
            color += sample * smoothstep(0.7, 1.0, brightness);
        }
    }
    return color / 25.0;
}

float apply_vignette(vec2 uv) {
    vec2 pos = uv - 0.5;
    float dist = length(pos);
    float vignette = smoothstep(0.8, 0.5, dist); // softened range
    return mix(1.0, vignette, vignette_strength); // gently blend
}

void fragment() {
    vec2 uv = UV;

    // Base color with chromatic aberration
    vec3 color = apply_chromatic_aberration(uv);

    // Add bloom
    vec3 bloom = apply_bloom(uv);
    color += bloom * bloom_strength;

    // Add grain/noise
    float grain = random(uv + time) * noise_strength;
    color += grain;

    // Vignette
    color *= apply_vignette(uv);

    // Slight flicker / brightness variation
    color *= 0.95 + 0.05 * sin(time * 4.0);

    // Tone curve (mild filmic look)
    color = pow(color, vec3(0.9));

    COLOR = vec4(color, 1.0);
}
