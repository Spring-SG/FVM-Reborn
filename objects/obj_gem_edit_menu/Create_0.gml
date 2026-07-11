image_xscale = 1.8
image_yscale = 1.8

target_card_index = -1
target_current_info = 0
target_max_info = 0
info_got = 0
view_max_shape = global.save_data.unlocked_items.max_gem_level

//target_current_level = 9
//target_current_shape = 0
//target_current_skill = 0

var btn1 = instance_create_depth(x-180,y+160,depth-1,obj_gem_edit_select_btn)
btn1.btn_type = "confirm"
btn1.btn_text = "确定"
var btn2 = instance_create_depth(x+180,y+160,depth-1,obj_gem_edit_select_btn)
btn2.btn_type = "cancel"
btn2.btn_text = "取消"
var btn7 = instance_create_depth(x,y+160,depth-1,obj_gem_edit_select_btn)
btn7.btn_type = "apply"
btn7.btn_text = "应用全部"
var target_list = ["level","shape","skill"]

for(var i = 0 ; i< 1 ; i++){
	var btn3 = instance_create_depth(x-200,y-70+80*i,depth-1,obj_gem_edit_btn)
	btn3.btn_type = "min"
	btn3.target_info = target_list[i]
	btn3.target_card_index = target_card_index
	btn3.view_max_shape = view_max_shape
	var btn4 = instance_create_depth(x-130,y-70+80*i,depth-1,obj_gem_edit_btn)
	btn4.btn_type = "subtract"
	btn4.target_info = target_list[i]
	btn4.target_card_index = target_card_index
	btn4.view_max_shape = view_max_shape
	var btn5 = instance_create_depth(x+130,y-70+80*i,depth-1,obj_gem_edit_btn)
	btn5.btn_type = "plus"
	btn5.target_info = target_list[i]
	btn5.target_card_index = target_card_index
	btn5.view_max_shape = view_max_shape
	var btn6 = instance_create_depth(x+200,y-70+80*i,depth-1,obj_gem_edit_btn)
	btn6.btn_type = "max"
	btn6.target_info = target_list[i]
	btn6.target_card_index = target_card_index
	btn6.view_max_shape = view_max_shape
}