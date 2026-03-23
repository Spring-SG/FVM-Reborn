if target_type == "normal" && row == other.row{
	var inst = instance_create_depth(x,y,depth,obj_xiaolongbao_bullet_effect)
	inst.sprite_index = spr_sausage_bullet_effect
		
	instance_destroy()
}