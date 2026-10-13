shader_type canvas_item;
uniform float clock = 0.0;
uniform bool flowing = true;
uniform bool lava = false;
void fragment(){
 vec2 drift = flowing ? vec2(sin(UV.y*16.0+clock*1.1),cos(UV.x*13.0+clock*.8))*.012 : vec2(0.0);
 vec4 c=texture(TEXTURE,UV+drift);
 float ripple=flowing ? sin((UV.x+UV.y)*24.0-clock*1.6)*.045 : 0.0;
 c.rgb+=vec3(ripple)*(lava ? vec3(1.0,.45,.08) : vec3(.4,.85,1.0));
 COLOR=c;
}
