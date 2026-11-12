#version 300 es
// Screen saturation. 1.0 = original, >1 more vivid, <1 more muted.
precision highp float;
in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;

const float SATURATION = 1.6;

void main() {
    vec4 c = texture(tex, v_texcoord);
    float luma = dot(c.rgb, vec3(0.2126, 0.7152, 0.0722));
    fragColor = vec4(clamp(mix(vec3(luma), c.rgb, SATURATION), 0.0, 1.0), c.a);
}
