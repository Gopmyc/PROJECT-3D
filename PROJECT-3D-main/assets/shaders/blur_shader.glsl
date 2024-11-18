// Gaussian blur shader
extern number radius;
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec4 sum = vec4(0.0);
    vec2 size = vec2(radius) / love_ScreenSize.xy;
    
    for (float x = -radius; x <= radius; x++) {
        for (float y = -radius; y <= radius; y++) {
            sum += Texel(texture, texture_coords + vec2(x, y) * size);
        }
    }
    
    return sum / ((radius * 2.0 + 1.0) * (radius * 2.0 + 1.0)) * color;
}
