image_xscale = 0.9
image_yscale = 0.9
image_speed = 0

is_submenu_opened = false
button_select = -1
target_cookbook_index = -1
y_offset = 0

current_cookbook_list = []

instance_create_depth(x+710,y-410,depth-1,obj_closecookbook_btn)

var btn1 = instance_create_depth(x-376,y-335,depth-5,obj_cookbook_select_btn)
btn1.btn_index = 0
btn1.btn_text = "上等佳肴"
var btn2 = instance_create_depth(x-376,y-280,depth-5,obj_cookbook_select_btn)
btn2.btn_index = 1
btn2.btn_text = "秘制佳肴"
var btn3 = instance_create_depth(x-376,y-225,depth-5,obj_cookbook_select_btn)
btn3.btn_index = 2
btn3.btn_text = "极品佳肴"


function refresh_cookbook_list(){
	instance_destroy(obj_cookbook_list_btn)
	//target_task_index = -1
	current_cookbook_list = []
	var cookbook_list = global.cookbook_list
	for(var i = 0;i < array_length(cookbook_list);i++){
		var cookbook_data = get_cookbook_data(cookbook_list[i])
		if (button_select == cookbook_data.rank){
			array_push(current_cookbook_list,cookbook_list[i])
			var inst = instance_create_depth(x-376,y-145+101*(array_length(current_cookbook_list)-1),depth-1,obj_cookbook_list_btn)
			inst.btn_index = array_length(current_cookbook_list)-1
			inst.cookbook_title = cookbook_data.title
			inst.spr_index = cookbook_data.icon
			inst.desc = cookbook_data.tiny_desc
			inst.cookbook_id = global.cookbook_list[i]
			inst.cookbook_rank = button_select
		}
	}
}
