precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;

void main() {
    vec4 texColor = texture2D(tex, v_texcoord);
    
    // Weighted grayscale (Rec. 709)
    // Green (0.71) carries the most weight, Blue (0.07) the least.
    float gray = dot(texColor.rgb, vec3(0.2126, 0.7152, 0.0722));
    
    gl_FragColor = vec4(vec3(gray), texColor.a);
}
