// Inherit the parent event
var inst = instance_create_depth(x,y,depth,obj_pineapple_explosive_bread_explosion)
inst.shape = shape
inst.grid_row = grid_row
if shape == 1{
	inst.sprite_index = spr_pineapple_explosive_bread_1_explosion
}
if shape == 2{
	inst.sprite_index = spr_pineapple_explosive_bread_2_explosion
}

event_inherited();

