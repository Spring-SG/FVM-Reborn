if global.is_paused{
	exit
}
timer ++
if state == "idle"{
	image_index = (timer/5) mod 9
	if timer == 8*60{
		timer = 0
		state = "act"
	}
}
if state == "act"{
	image_index = (timer/5) mod 10 + 9
	if timer == 50{
		timer = 0
		state = "idle"
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