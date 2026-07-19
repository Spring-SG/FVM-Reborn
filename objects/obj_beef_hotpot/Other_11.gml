var inst = instance_create_depth(x+50,y-75,depth-500,obj_coffeepot_bullet)
audio_play_sound(snd_coffee_pot_attack,0,0)
inst.damage = atk * 10
inst.move_speed = 0
inst.image_alpha = 0
inst.shape = shape
inst.row = grid_row
inst.start_col = grid_col