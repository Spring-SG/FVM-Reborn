var inst = instance_create_depth(x-40,y-45,depth-500,obj_coalstarfish_bullet)
inst.damage = atk
inst.move_speed = -8
inst.row = grid_row
inst.b_type = 1
if shape == 1{
	inst.sprite_index = spr_coalstarfish_bullet_1
}
if shape == 2{
	inst.sprite_index = spr_coalstarfish_bullet_2
}

var inst2 = instance_create_depth(x,y-45,depth-500,obj_coalstarfish_bullet)
inst2.damage = atk
inst2.move_speed = 0
inst2.y_move_speed = 8
inst2.image_angle = 90
if shape == 1{
	inst2.sprite_index = spr_coalstarfish_bullet_1
}
if shape == 2{
	inst2.sprite_index = spr_coalstarfish_bullet_2
}

var inst3 = instance_create_depth(x,y-95,depth-500,obj_coalstarfish_bullet)
inst3.damage = atk
inst3.move_speed = 0
inst3.y_move_speed = -8
inst3.image_angle = -90
if shape == 1{
	inst3.sprite_index = spr_coalstarfish_bullet_1
}
if shape == 2{
	inst3.sprite_index = spr_coalstarfish_bullet_2
}

var inst4 = instance_create_depth(x+40,y-45,depth-500,obj_coalstarfish_bullet)
inst4.damage = atk
inst4.move_speed = 5
inst4.y_move_speed = -3
inst4.image_angle = -145
if shape == 1{
	inst4.sprite_index = spr_coalstarfish_bullet_1
}
if shape == 2{
	inst4.sprite_index = spr_coalstarfish_bullet_2
}

var inst5 = instance_create_depth(x+40,y-45,depth-500,obj_coalstarfish_bullet)
inst5.damage = atk
inst5.move_speed = 5
inst5.y_move_speed = 3
inst5.image_angle = 145
if shape == 1{
	inst5.sprite_index = spr_coalstarfish_bullet_1
}
if shape == 2{
	inst5.sprite_index = spr_coalstarfish_bullet_2
}