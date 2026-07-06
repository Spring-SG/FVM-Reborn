if instance_exists(target_boss){
	hp = target_boss.hp
	if hp < 0 hp = 0
	maxhp = target_boss.maxhp
	hp_rate = hp/maxhp
}
else{
		hp = 0
		maxhp = 0
		hp_rate = 0
}


if boss_id != ""{
	icon_spr = global.boss_list[? boss_id].icon
	boss_name = global.boss_list[? boss_id].name
}
var icon_height = sprite_height * 1.8
draw_set_color(bg_color)
draw_rectangle(x,y+6,x+(bar_width+28),y+icon_height/2-10,false)
draw_sprite_ext(spr_boss_hpbar_bar,0,x,y+icon_height/4,((bar_width+30)*hp_rate)/2,1.8,0,c_white,1)
if obj_battle.boss_count < 2{
	draw_sprite_ext(spr_boss_hpbar_icon_bg,0,x,y,1.8,1.8,0,c_white,1)
}
draw_sprite_ext(spr_boss_hpbar_left,0,x,y+icon_height/4,1.8,1.8,0,c_white,1)
draw_sprite_ext(spr_boss_hpbar_middle,0,x+9*1.8,y+icon_height/4,bar_width/3,1.8,0,c_white,1)
draw_sprite_ext(spr_boss_hpbar_right,0,x+9*1.8+bar_width,y+icon_height/4,1.8,1.8,0,c_white,1)
if obj_battle.boss_count < 2{
	draw_sprite_ext(spr_boss_hpbar_name,0,x,y-icon_height/4 + 2,1.8,1.8,0,c_white,1)
	draw_set_valign(fa_middle)
	draw_set_halign(fa_center)
	draw_set_font(font_hei)
	draw_set_colour(c_white)
	draw_text(x + bar_width / 2 , y+icon_height/4,string(hp)+"/"+string(maxhp)+"("+string(hp_rate*100)+"%)")
	draw_set_font(font_yuan)
	draw_set_colour(c_black)
	draw_text(x+68,y-icon_height/4 + 4,boss_name)
	draw_set_valign(fa_left)
	draw_set_halign(fa_top)
}
else{
	draw_sprite_ext(spr_boss_hpbar_name,0,x-135,y+icon_height/4 ,1.8,1.8,0,c_white,1)
	draw_set_valign(fa_middle)
	draw_set_halign(fa_center)
	draw_set_font(font_hei)
	draw_set_colour(c_white)
	draw_text(x + bar_width / 2 , y+icon_height/4,string(hp)+"/"+string(maxhp)+"("+string(hp_rate*100)+"%)")
	draw_set_font(font_yuan)
	draw_set_colour(c_black)
	draw_text(x+68-135,y + 2 +icon_height/4,boss_name)
	draw_set_valign(fa_left)
	draw_set_halign(fa_top)
}
if obj_battle.boss_count < 2{
	draw_sprite_ext(icon_spr,0,x-3,y,1.8,1.8,0,c_white,1)
}