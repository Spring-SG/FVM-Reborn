if !global.laboretory_room{
	var is_drop = random_range(0,100)
	if is_drop < 10{
		instance_create_depth(x,y-50,depth-200,obj_coin)
	}
}