
draw_sprite_ext(spr_flame_indicator,0,350,0,1.8,1.8,0,c_white,1)
var slot_length = ds_list_size(global.selected_deck)
//show_debug_message("slot_length:"+string(slot_length))
if slot_length <= 14{
	draw_sprite_ext(spr_slot_top,0,350+83*1.8,0,40+45*(slot_length-1),1.8,0,c_white,1)
	if not instance_exists(obj_shovel_slot){
		instance_create_depth(350+83*1.8+80+90*(slot_length-1),0,-980,obj_shovel_slot)
	}
}
else{
	draw_sprite_ext(spr_slot_top,0,350+83*1.8,0,40+45*(15-1),1.8,0,c_white,1)
	draw_sprite_ext(spr_slot_corner,0,350+83*1.8+80+90*(15-1),0,1.8,1.8,0,c_white,1)
	draw_sprite_ext(spr_slot_right,0,350+83*1.8+80+90*(15-1)-1,18*1.8,1.8,118*(slot_length-14),0,c_white,1)
	if not instance_exists(obj_shovel_slot){
		instance_create_depth(350+83*1.8+80+90*(14-1)-33,118*(slot_length-14)+17,-980,obj_shovel_slot)
	}
}
draw_set_halign(fa_center)
draw_set_valign(fa_middle)
draw_set_font(font_hei)
draw_set_color(c_black)
draw_text(420,143,string(global.flame))
draw_set_halign(fa_left)
draw_set_valign(fa_top)

