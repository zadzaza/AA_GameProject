shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0); // Цвет контура
uniform float outline_thickness : hint_range(0.0, 10.0) = 1.0; // Толщина контура

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    if (tex.a == 0.0) {
        // Проверка соседних пикселей
        for (int x = -1; x <= 1; x++) {
            for (int y = -1; y <= 1; y++) {
                if (x == 0 && y == 0) continue;
                vec2 offset = vec2(float(x), float(y)) * outline_thickness / TEXTURE_PIXEL_SIZE;
                vec4 neighbor_tex = texture(TEXTURE, UV + offset);
                if (neighbor_tex.a > 0.0) {
                    tex = outline_color;
                    break;
                }
            }
            if (tex == outline_color) break;
        }
    }
    COLOR = tex;
}
