var inst = instance_create_depth(x+40,y-75,depth-500,obj_xiaolongbao_bullet)
inst.damage = atk
inst.move_speed = 8
inst.row = grid_row

var inst2 = instance_create_depth(x,y-95,depth-500,obj_xiaolongbao_bullet_vertical)
inst2.damage = atk
inst2.move_speed = 8
inst2.col = grid_col
inst2.image_angle = -90

var inst3 = instance_create_depth(x,y-95,depth-500,obj_xiaolongbao_bullet_vertical)
inst3.damage = atk
inst3.move_speed = -8
inst3.col = grid_col
inst3.image_angle = 90