if global.lose_focus_pause{
	if !window_has_focus(){
		audio_pause_all()
		audio_pause = true
	}
	else{
		if audio_pause{
			audio_resume_all()
			audio_pause = false
		}
	}
}