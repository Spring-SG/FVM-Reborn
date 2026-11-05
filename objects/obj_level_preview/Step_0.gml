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
		// BOSS 区格子更宽（横 340 / 纵 280），裁剪框相应放大，免得 BOSS 被裁太多
		// 缩放不用改：instance 的 is_boss 会让它走 scale_boss 那一档
		inst.is_boss    = true
		inst.clip_box_w = 300
		inst.clip_box_h = 250
		array_push(mouse_preview_inst,inst)
	}
}
if keyboard_check_pressed(vk_escape) || mouse_check_button_pressed(mb_right){
	instance_destroy()
}