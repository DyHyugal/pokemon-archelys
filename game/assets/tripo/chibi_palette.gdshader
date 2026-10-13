shader_type spatial;
uniform sampler2D base_texture : source_color, filter_linear_mipmap, repeat_enable;
uniform vec4 skin_tint : source_color = vec4(1.0);
uniform vec4 shirt_tint : source_color = vec4(1.0);
uniform vec4 pants_tint : source_color = vec4(1.0);
uniform vec4 hair_tint : source_color = vec4(1.0);
uniform bool change_skin = false;
uniform bool change_shirt = false;
uniform bool change_pants = false;
uniform bool change_hair = false;
varying vec3 local_position;
void vertex() { local_position = VERTEX; }
void fragment() {
 vec3 c = texture(base_texture, UV).rgb;
 float h = local_position.y;
 bool warm = c.r > c.g * 1.08 && c.g > c.b * 1.05;
 if (change_skin && warm && c.r > 0.52) c *= skin_tint.rgb / vec3(0.75, 0.56, 0.40);
 else if (change_hair && h > 0.59 && warm && c.r < 0.52) c *= hair_tint.rgb / vec3(0.23, 0.12, 0.045);
 else if (change_shirt && h > 0.29 && h < 0.56 && c.g > c.r * 1.1 && c.g > c.b * 1.02) c *= shirt_tint.rgb / vec3(0.12, 0.40, 0.28);
 else if (change_pants && h > 0.17 && h < 0.30 && abs(local_position.x) < 0.17) c *= pants_tint.rgb / vec3(0.63, 0.57, 0.42);
 ALBEDO = clamp(c, vec3(0.0), vec3(1.0));
 ROUGHNESS = 0.92;
 SPECULAR = 0.18;
}
