
var inst2 = instance_create_depth(x+40,y-70,depth-500,obj_pizzaoven_bullet)
inst2.damage = atk
inst2.move_speed = 8
inst2.row = grid_row
inst2.target_x = get_world_position_from_grid(8,0).x+60
if instance_exists(target_instance){
	inst2.target_x = target_instance.x
	inst2.target_enemy = target_instance
}
if shape == 1{
	inst2.sprite_index = spr_pizza_oven_bullet_1
}
if shape == 2{
	inst2.sprite_index = spr_pizza_oven_bullet_2
}