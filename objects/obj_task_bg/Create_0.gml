image_xscale = 0.9
image_yscale = 0.9
image_speed = 0

is_submenu_opened = false
button_select = -1
target_task_index = -1
y_offset = 0

current_task_list = []

instance_create_depth(x+680,y-450,depth-1,obj_closetask_btn)
instance_create_depth(x+300,y+400,depth-1,obj_task_claim_btn)

var btn1 = instance_create_depth(x-400,y-290,depth-1,obj_task_select_btn)
btn1.btn_index = 0
btn1.btn_text = "主线任务"
var btn2 = instance_create_depth(x-400,y-235,depth-1,obj_task_select_btn)
btn2.btn_index = 1
btn2.btn_text = "支线任务"
var btn3 = instance_create_depth(x-400,y-180,depth-1,obj_task_select_btn)
btn3.btn_index = 2
btn3.btn_text = "挑战任务"

//检查卡片强化任务是否完成
function check_card_upgrade(){
	for(var i = 0 ; i < array_length(global.save_data.tasks) ; i++){
		var task_id = global.save_data.tasks[i].id
		if global.save_data.tasks[i].state != "completed" && global.save_data.tasks[i].state != "claimed"{
			var task_data = get_task_data(task_id)
			var complete_require = array_length(task_data.requirements)
			var complete_count = 0
			for(var j = 0 ; j < array_length(task_data.requirements) ; j++){
				//根据任务类型，判断是否完成
				//卡片强化类任务
				if task_data.requirements[j].type == "card_upgrade"{
					//先重置进度
					edit_task_progress(task_id,j,0)
					//遍历检查所有卡片等级
					for(var k = 0 ; k < array_length(global.save_data.unlocked_cards) ; k++){
						if global.save_data.unlocked_cards[k].max_level >= task_data.requirements[j].target_card_level{
							add_task_progress(task_id,j,1)
						}
					}
					//如果进度满足要求，则增加完成计数
					if get_task_progress(task_id,j) >= task_data.requirements[j].require{
						complete_count++
					}
				}
			}
			//如果所有任务要求均达成，则完成任务
			if complete_count >= complete_require{
				edit_task_state(task_id,"completed")
			}
		}
	}
}


function refresh_task_list(){
	check_card_upgrade()
	instance_destroy(obj_task_line_bg)
	y_offset = 0
	//target_task_index = -1
	current_task_list = []
	var saved_task_list = global.save_data.tasks
	for(var i = 0;i < array_length(saved_task_list);i++){
		var task_data = get_task_data(saved_task_list[i].id)
		if (button_select == 0 && task_data.type == "main_task")
		|| (button_select == 1 && task_data.type == "side_task")
		|| (button_select == 2 && task_data.type == "challenge_task"){
			array_push(current_task_list,saved_task_list[i])
			var inst = instance_create_depth(x-400,y-130+52*(array_length(current_task_list)-1),depth-1,obj_task_line_bg)
			inst.btn_index = array_length(current_task_list)-1
			// 瀑布流入场（等级 2）：本页从上往下依次延迟 2 帧（与食神谱 obj_cookbook_bg:37 同款）
			inst.wf_t = ui_anim_on(2) ? -(inst.btn_index * 2) : 18
			inst.task_title = task_data.title
			inst.state = saved_task_list[i].state
		}
	}
}

// 整块面板的进出场过渡（实现在 scripts/GuiStack/GuiStack.gml）
panel_anim_init(id, 0.28, 0.18, 260)
panel_anim_kids(id, [obj_closetask_btn, obj_task_claim_btn, obj_task_line_bg, obj_task_select_btn])