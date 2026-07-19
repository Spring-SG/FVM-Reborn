// Inherit the parent event
event_inherited();

if global.is_paused{
	exit
}

if instance_exists(train_head){
	if state == BOSS_STATE.SKILL1 && timer >= 10 * 5 && timer <= 46*5{
		var train_index = array_get_index(train_head.train_body_list,id)
		if train_index != -1{
			draw_set_colour(c_white)
			draw_text(x,y,$"{train_head.skill_1_damage[train_index]}/{0.01*maxhp}")
		}
	}
}