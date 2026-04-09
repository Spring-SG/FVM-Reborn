if button_pushed{
	timer ++
	if timer < 16{
		image_index = floor(timer / 4)
	}
	else{
		audio_pause_sound(mus_readyroom)
		room_goto(room_battle)
		texture_prefetch("bullet")
		texture_prefetch("effects")
	}
}