if grow_timer < grow_time{
	var inst = instance_create_depth(x, y - 60, depth - 1000, obj_flame);
	inst.value = flame_produce - 10
	inst.sprite_index = spr_flame_small
	if shape == 2{
		var inst2 = instance_create_depth(x, y - 60, depth - 1000, obj_flame);
		inst2.value = flame_produce-10
		inst2.sprite_index = spr_flame_small
	}
}
else{
	var inst = instance_create_depth(x, y - 60, depth - 1000, obj_flame);
	inst.value = flame_produce
	if shape == 2{
		var inst2 = instance_create_depth(x, y - 60, depth - 1000, obj_flame);
		inst2.value = flame_produce
	}
}