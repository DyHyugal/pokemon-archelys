shader_type canvas_item;
uniform bool recolor_shirt=false;
uniform vec4 shirt:source_color=vec4(1.0);
void fragment(){
 vec4 c=texture(TEXTURE,UV);vec2 px=TEXTURE_PIXEL_SIZE;
 float edge=max(max(texture(TEXTURE,UV+vec2(px.x,0)).a,texture(TEXTURE,UV-vec2(px.x,0)).a),max(texture(TEXTURE,UV+vec2(0,px.y)).a,texture(TEXTURE,UV-vec2(0,px.y)).a));
 if(c.a<.15){c=vec4(.20,.24,.18,edge*.65);}else{
  if(recolor_shirt && c.g>c.r*1.2 && c.b>c.r*1.15 && c.g>.3)c.rgb=mix(c.rgb,shirt.rgb*(.5+c.g*.6),.85);
  c.rgb=mix(c.rgb,floor(c.rgb*24.0+.5)/24.0,.2);
 }
 COLOR=c;
}
