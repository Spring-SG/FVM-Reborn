if btn_index >= obj_task_bg.y_offset && btn_index <= obj_task_bg.y_offset + 10{
	y = obj_task_bg.y-130+52*(btn_index-obj_task_bg.y_offset)
}
else{
	y = -1000
}