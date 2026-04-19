if array_length(mouse_preview_inst) == 0{
	for(var i = 0; i < array_length(enemy_type_list);i++){
		var enemy_data = global.enemy_map[? enemy_type_list[i]]
		var inst = instance_create_depth(300+(i mod 10)*170,300+floor(i / 10)*230,depth-1,obj_mouse_preview)
		inst.sprite_index = enemy_data.spr
		inst.tooltip_text = enemy_data.description + "\n基础生命值：" + string(enemy_data.hp)
		if enemy_data.shield > 0{
			inst.tooltip_text += "\n防具血量：" + string(enemy_data.shield)
		}
		array_push(mouse_preview_inst,inst)
	}
	for(var i = 0; i < array_length(boss_type_list);i++){
		var enemy_data = global.enemy_map[? boss_type_list[i]]
		var inst = instance_create_depth(300+(i mod 5)*340,900+floor(i / 5)*280,depth-1,obj_mouse_preview)
		inst.sprite_index = enemy_data.spr
		inst.tooltip_text = enemy_data.description + "\n基础生命值：" + string(enemy_data.hp)
		array_push(mouse_preview_inst,inst)
	}
}
if keyboard_check_pressed(vk_escape){
	instance_destroy()
}