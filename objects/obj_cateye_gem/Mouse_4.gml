if cooldown_timer <= 0{
	audio_play_sound(snd_button,0,0)
	
	var text = instance_create_depth(room_width/2+80,room_height/3-100,-500,obj_gem_text)
	text.sprite_index = spr_cateye_gem_text
	
	var real_range = range - 1
	var up_range = floor(real_range/2)
	var down_range = ceil(real_range/2)
	var start_row = obj_player_character.grid_row
	if start_row - up_range < 0{
		start_row = up_range
	}
	if start_row + down_range > global.grid_rows - 1{
		start_row = global.grid_rows - down_range - 1
	}
	var inst_pos1 = get_world_position_from_grid(-1,start_row){
		var inst1 = instance_create_depth(inst_pos1.x-10,inst_pos1.y+10,-500,obj_cat)
		inst1.row = start_row
		inst1.state = "attack"
		inst1.can_loss = false
	}
	for(var i = 1;i<=up_range;i++){
		var inst_pos = get_world_position_from_grid(-1,start_row-i)
		var inst = instance_create_depth(inst_pos1.x-10,inst_pos.y+10,-500,obj_cat)
		inst.row = start_row-i
		inst.state = "attack"
		inst.can_loss = false
	}
	for(var i = 1;i<=down_range;i++){
		var inst_pos = get_world_position_from_grid(-1,start_row+i)
		var inst = instance_create_depth(inst_pos1.x-10,inst_pos.y+10,-500,obj_cat)
		inst.row = start_row+i
		inst.state = "attack"
		inst.can_loss = false
	}
	
	cooldown_timer = cooldown
}