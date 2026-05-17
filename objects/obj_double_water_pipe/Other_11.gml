b_count++

if b_count == 1 || (b_count >= 2 && shape >= 1){
	var inst = instance_create_depth(x+40,y-75,depth-500,obj_waterpipe_bullet)
	inst.damage = atk
	inst.move_speed = 8
	inst.row = grid_row
	if card_equipped_attire_id(plant_id) == "water_pipe_libra"{
		inst.sprite_index = spr_water_pipe_libra_bullet
	}
}

var inst2 = instance_create_depth(x-40,y-75,depth-500,obj_waterpipe_bullet)
inst2.damage = atk
inst2.move_speed = -8
inst2.row = grid_row
inst2.image_angle = 180
if card_equipped_attire_id(plant_id) == "water_pipe_libra"{
	inst2.sprite_index = spr_water_pipe_libra_bullet
}

audio_play_sound(snd_shot, 0, 0);