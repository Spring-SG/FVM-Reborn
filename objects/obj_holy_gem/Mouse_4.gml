if cooldown_timer <= 0{
	global.audio.play(snd_button,0,0)
	
	var text = instance_create_depth(room_width/2+80,room_height/3-100,-500,obj_gem_text)
	text.sprite_index = spr_holy_gem_text
	
	var grid_pos = get_world_position_from_grid(4,3)
	var inst = instance_create_depth(grid_pos.x,grid_pos.y-200,-800,obj_holy_gem_effect)
	inst.max_time = max_time

	cooldown_timer = cooldown
}