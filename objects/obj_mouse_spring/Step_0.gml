if global.is_paused{
	exit
}
timer ++
if state == "idle"{
	image_index = 0
	if left_use_times <= 0{
		timer = 0
		state = "death"
	}
}
if state == "act"{
	image_index = (timer/5) mod 9
	if timer == 9 * 5 - 1{
		timer = 0
		state = "idle"
	}
}
if state == "death"{
	image_index = 0
	image_alpha -= 0.1
	if image_alpha <= 0{
		instance_destroy()
	}
}
for(var i = 0 ; i < array_length(enemy_list) ; i++){
	if !instance_exists(enemy_list[i]) || enemy_left_time[i] <= 0{
		array_delete(enemy_list,i,1)
		array_delete(enemy_left_time,i,1)
		continue
	}
	if enemy_list[i].hp > 0{
		enemy_list[i].x -= (8-enemy_list[i].move_speed)
		enemy_left_time[i] -= 1
	}
}