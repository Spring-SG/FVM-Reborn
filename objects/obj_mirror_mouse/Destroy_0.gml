// Inherit the parent event
event_inherited();

if return_flame > 0{
	var inst = instance_create_depth(x,y-80,-800,obj_flame)
	inst.value = return_flame
}

with obj_flame{
	is_capture = false
	speed = 0
}