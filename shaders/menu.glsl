extern vec2 resolution; // Screen resolution
extern float time;      // Current time

// Random number generator based on coordinates
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

// Smooth noise function
float noise(vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    // Four corners of the grid
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    // Smooth interpolation
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

vec4 effect(vec4 color, Image texture, vec2 tex_coords, vec2 screen_coords) {
    // Normalize coordinates (-1 to 1)
    vec2 uv = (screen_coords / resolution) * 2.0 - 1.0;
    uv.x *= resolution.x / resolution.y; // Keep aspect ratio

    // Generate a moving wave pattern
    float wave = sin(uv.x * 4.0 + time * 2.0) * 0.05 + sin(uv.y * 6.0 - time * 3.0) * 0.05;

    // Create a gradient background
    float gradient = uv.y * 0.2 + 0.2;

    // Add noise to the background
    float n = noise(uv * 10.0 + vec2(time * 0.5)); // Adjust scale and movement of noise
    n = n * 0.2; // Scale down noise intensity

    // Combine wave, gradient, and noise
    float brightness = gradient + wave + n;

    // Add a glow effect
    vec3 baseColor = vec3(0.2118, 0.0706, 0.4667); // Base color
    vec3 glowColor = vec3(0.8, 0.2, 0.2); // Glow color
    vec3 finalColor = baseColor * brightness + glowColor * wave * 0.5;

    return vec4(finalColor, 1.0); // Return final color with full alpha
}
