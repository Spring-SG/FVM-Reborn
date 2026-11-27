if !obj_readyroom_manager.is_submenu_open{
	global.audio.play(snd_button,0,0)
	var inst = instance_create_depth(0,0,-500,obj_level_preview)
	inst.enemy_type_list = obj_readyroom_manager.enemy_type_list
	inst.boss_type_list = obj_readyroom_manager.boss_type_list
}