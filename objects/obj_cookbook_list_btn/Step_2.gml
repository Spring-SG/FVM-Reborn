
if btn_index >= obj_cookbook_bg.y_offset && btn_index <= obj_cookbook_bg.y_offset + 5{
	y = obj_cookbook_bg.y-145+101*(btn_index-obj_cookbook_bg.y_offset)
}
else{
	y = -1000
}

banding_btn.y = y
banding_btn.cookbook_id = cookbook_id
banding_btn.cookbook_rank = cookbook_rank