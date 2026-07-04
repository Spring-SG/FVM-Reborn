for(var i = 0 ; i < (bun_count+1) ; i++){
	var inst = instance_create_depth(x+20*i,y-80,depth-500,bullet_list[i].bullet_type)
	inst.damage = bullet_list[i].damage
	inst.move_speed = 8
	inst.row = grid_row
}