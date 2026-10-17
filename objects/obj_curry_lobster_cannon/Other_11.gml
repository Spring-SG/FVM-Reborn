var target = find_priority_enemy()
if target != noone{
	var inst = instance_create_depth(x,y-90,depth-1,obj_currylobstercannon_bullet)
	inst.target_col = target.col
	inst.target_row = target.row
	inst.damage = atk
	inst.b_shape = shape

	if shape == 1{
		inst.sprite_index = spr_curry_lobster_cannon_bullet_1
	}
	if shape == 2{
		inst.sprite_index = spr_curry_lobster_cannon_bullet_2
	}
	
	if card_equipped_attire_id(plant_id) == "lobster_athena"{
		inst.sprite_index = spr_lobster_athena_bullet
		inst.image_alpha = 0
	}
}