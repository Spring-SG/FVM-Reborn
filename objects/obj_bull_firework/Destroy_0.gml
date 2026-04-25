var __count__ = 1
if shape >= 2 __count__ = 3
var start = 0
if shape >= 2 start = -1

for(var i = 0 ; i < __count__ ; i++){
	if grid_row + start + i > -1 && grid_row + start + i < global.grid_rows{
		var grid_pos = get_world_position_from_grid(-1,grid_row+start+i)
		var cat_inst = instance_create_depth(grid_pos.x - 10, grid_pos.y+10, 0,obj_cat);
		cat_inst.row = grid_row
		cat_inst.idle_anim = 0
		cat_inst.awake_anim = 0
		cat_inst.attack_anim = 8
		cat_inst.flash_speed = 4
		cat_inst.move_speed = 8
		cat_inst.state = "attack"
		cat_inst.can_loss = false
		cat_inst.sprite_index = spr_bull_firework_bullet
		if shape == 1{
			cat_inst.sprite_index = spr_bull_firework_bullet_1
		}
		if shape == 2{
			cat_inst.sprite_index = spr_bull_firework_bullet_2
		}
	}
}


// 播放攻击声音
audio_play_sound(snd_coke_bomb_explode, 0, false);
	 
var effect_inst = instance_create_depth(x,y,depth,obj_coke_bomb_explode)
if shape == 0 {
	effect_inst.sprite_index = spr_bull_firework_effect
}
else if shape == 1{
	effect_inst.sprite_index = spr_bull_firework_effect_1
}
else if shape == 2{
	effect_inst.sprite_index = spr_bull_firework_effect_2
}
event_inherited()