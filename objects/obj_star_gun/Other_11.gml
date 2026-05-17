var inst = instance_create_depth(x+40,y+50,depth-500,obj_xiaolongbao_bullet)
inst.damage = atk
inst.move_speed = 8
inst.row = grid_row
inst.sprite_index = spr_stargun_bullet

var inst2 = instance_create_depth(x+80,y+50,depth-500,obj_xiaolongbao_bullet)
inst2.damage = atk
inst2.move_speed = 8
inst2.row = grid_row
inst2.sprite_index = spr_stargun_bullet