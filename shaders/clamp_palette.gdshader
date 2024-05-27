// Author: dannflor (on Lospec Jam 2 Discord forum)
// Effect: clamp any color on the canvas to the nearest color in a given color palette
// Usage:
// - put this on a color rect on a canvas layer over everything else (use anchor mode full to cover the whole screem)
// - and provide a Nx1 image of the palette to the shader uniform, where N is the number of colors in the palette

shader_type canvas_item;
render_mode blend_mix;

uniform sampler2D palette: filter_nearest;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
void fragment() {
    vec3 source_col = texture(screen_texture, SCREEN_UV).rgb;
    vec3 closest_col = vec3(0.0);
    float smallest_error = 10.0;

    int palette_size = textureSize(palette, 0).x;
    float palette_pixel_size = 1.0 / float(palette_size);
    for (int x = 0; x <= palette_size; x++) {
        vec3 palette_col = texture(palette, vec2(float(x) * palette_pixel_size, 0.0)).rgb;
        float error = distance(source_col, palette_col);
        if (error < smallest_error) {
            closest_col = palette_col;
            smallest_error = error;
        }
    }
    COLOR.rgb = closest_col;
}