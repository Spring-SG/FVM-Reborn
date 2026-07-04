for(var i = 0 ; i < (bun_count+1) ; i++){
	var inst = instance_create_depth(x+20*i,y-80,depth-500,bullet_list[i].bullet_type)
	inst.damage = bullet_list[i].damage
	inst.move_speed = 8
	inst.row = grid_row
	
	var v_bullet = obj_xiaolongbao_bullet_vertical
	if bullet_list[i].bullet_type == obj_icelongbao_bullet{
		v_bullet = obj_icelongbao_bullet_vertical
	}
	
	var inst2 = instance_create_depth(x,y-95+20*i,depth-500,v_bullet)
	inst2.damage = bullet_list[i].damage
	inst2.move_speed = 8
	inst2.col = grid_col
	inst2.image_angle = -90

	var inst3 = instance_create_depth(x,y-95-20*i,depth-500,v_bullet)
	inst3.damage = bullet_list[i].damage
	inst3.move_speed = -8
	inst3.col = grid_col
	inst3.image_angle = 90
}