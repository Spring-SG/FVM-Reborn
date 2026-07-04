varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 in_origin;
uniform vec2 in_size;
uniform float in_radius;

void main()
{
    vec2 global_pixel_pos = vec2(gl_FragCoord.x, gl_FragCoord.y);

    vec2 local_pixel_pos = global_pixel_pos - in_origin;

    vec2 half_size = in_size * 0.5;

    vec2 pos_from_center = local_pixel_pos - half_size;

    vec2 q = abs(pos_from_center) - (half_size - vec2(in_radius));
    float d = length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - in_radius;

    float edge = 1.0; 
    float alpha = 1.0 - smoothstep(-edge, edge, d);

    if (alpha <= 0.0) {
        discard;
    }

    vec4 tex_color = texture2D(gm_BaseTexture, v_vTexcoord);
    gl_FragColor = v_vColour * tex_color * vec4(1.0, 1.0, 1.0, alpha);
}
