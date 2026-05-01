var inst = instance_create_depth(x+40,y-75,depth-500,obj_xiaolongbao_bullet)
inst.damage = atk
inst.move_speed = 8
inst.row = grid_row
if card_equipped_attire_id(plant_id) == "gatling_popcorn"{
	inst.sprite_index = spr_gatling_popcorn_bullet
	if shape == 1{
		inst.sprite_index = spr_gatling_popcorn_bullet_1
	}
	if shape == 2{
		inst.sprite_index = spr_gatling_popcorn_bullet_2
	}
}