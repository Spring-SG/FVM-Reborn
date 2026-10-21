if !hit_enemy{
	if other.hp > 0 and row == other.grid_row  and can_hit(target_type,other.target_type){
		with(other){
			global.audio.play(snd_egg_bullet,0,0)
			damage_amount = other.damage
			damage_type = other.damage_type
			event_user(0)
	
		}
		var inst = instance_create_depth(x,y,depth,obj_coke_bomb_explode)
		inst.sprite_index = spr_roast_lizard_pult_bullet_effect
		hit_enemy = true
		hitted_enemy = other.id
		instance_destroy()
	}
}