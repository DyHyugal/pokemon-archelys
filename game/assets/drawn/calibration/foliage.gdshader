shader_type canvas_item;
uniform float clock=0.0;
uniform float phase=0.0;
uniform float height=450.0;
uniform float opacity=1.0;
uniform bool flowing=true;
void vertex(){
 float upper=clamp(-VERTEX.y/height,0.0,1.0);
 VERTEX.x += flowing ? sin(clock*1.15+phase)*upper*upper*4.0 : 0.0;
}
void fragment(){COLOR=texture(TEXTURE,UV);COLOR.a*=opacity;}
