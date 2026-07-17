var target = find_priority_enemy()
var inst = instance_create_depth(x,y-95,depth-500,obj_tanghulu_bullet)
inst.damage = atk
inst.move_speed = 10
inst.target_enemy = target
inst.banding_card_obj = id
inst.row = grid_row
if shape == 1{inst.sprite_index = spr_tanghulu_bullet_1}
if shape == 2{inst.sprite_index = spr_tanghulu_bullet_2}