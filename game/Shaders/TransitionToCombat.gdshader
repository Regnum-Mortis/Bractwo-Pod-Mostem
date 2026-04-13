shader_type canvas_item;

uniform float radius : hint_range(0.0, 2.0) = 1.0;
// środek ekranu w UV (0.5, 0.5 = centrum)
uniform vec2 center = vec2(0.5, 0.5);
// stosunek ekranu żeby kółko nie było elipsą
uniform vec2 aspect = vec2(1.777, 1.0);  // 16:9

void fragment() {
    vec2 uv = (UV - center) * aspect;
    float dist = length(uv);

    if (dist < radius) {
        COLOR.a = 0.0;  // przezroczyste — widać grę
    } else {
        COLOR = vec4(0.0, 0.0, 0.0, 1.0);  // czarne
    }
}