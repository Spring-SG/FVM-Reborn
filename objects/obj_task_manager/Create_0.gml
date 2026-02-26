card_loss = 0
cat_loss = 0
flame_left = 0
not_equip_weapon = false
not_use_designated_card = false

card_group = {
	"bomb":["coke_bomb","kettle_bomb","flour_sack","steel_wool","mouse_clip","wine_bottle_bomb","ice_bucket_bomb","chocolate_cannon"]
}

function reset_task_state(){
	card_loss = 0
	cat_loss = 0
	flame_left = 0
	not_equip_weapon = false
	not_use_designated_card = false
}
function refresh_task_progress(){
	flame_left = global.flame
	//检查未携带武器任务
	if global.save_data.equipped_items.main_weapon.id == ""
	&& global.save_data.equipped_items.secondary_weapon.id == ""
	&& global.save_data.equipped_items.super_weapon.id == ""{
		not_equip_weapon = true
	}
	//检查猫损失量
	cat_loss = global.grid_rows
	with obj_cat{
		other.cat_loss--
	}
	for(var i = 0 ; i < array_length(global.save_data.tasks) ; i++){
		var task_id = global.save_data.tasks[i].id
		if global.save_data.tasks[i].state != "completed"  && global.save_data.tasks[i].state != "claimed"{
			var task_data = get_task_data(task_id)
			var complete_require = array_length(task_data.requirements)
			var complete_count = 0
			for(var j = 0 ; j < array_length(task_data.requirements) ; j++){
				//根据任务类型，判断是否完成
				//通关类任务
				if task_data.requirements[j].type == "level_complete"{
					//如果当前关卡id与要求相同，则增加进度
					if global.level_data.id == task_data.requirements[j].target_level{
						add_task_progress(task_id,j,1)
					}
					//如果进度满足要求，则增加完成计数
					if get_task_progress(task_id,j) >= task_data.requirements[j].require{
						complete_count++
					}
				}
				//剩余火苗类任务
				if task_data.requirements[j].type == "flame_left"{
					//增加火苗进度
					
					add_task_progress(task_id,j,flame_left)
					
					//如果进度满足要求，则增加完成计数
					if get_task_progress(task_id,j) >= task_data.requirements[j].require{
						complete_count++
					}
				}
				//不携带装备类任务
				if task_data.requirements[j].type == "weapon_limit"{
					//如果没有携带装备，则增加进度
					if not_equip_weapon{
						add_task_progress(task_id,j,1)
					}
					//如果进度满足要求，则增加完成计数
					if get_task_progress(task_id,j) >= task_data.requirements[j].require{
						complete_count++
					}
				}
				//不损失猫类任务
				if task_data.requirements[j].type == "cat_loss"{
					//增加猫损失数量
					add_task_progress(task_id,j,cat_loss)
					//如果进度满足要求，则增加完成计数
					if get_task_progress(task_id,j) <= task_data.requirements[j].require{
						complete_count++
					}
				}
				//不损失卡片类任务
				if task_data.requirements[j].type == "card_loss"{
					//增加卡片损失数量
					add_task_progress(task_id,j,card_loss)
					//如果进度满足要求，则增加完成计数
					if get_task_progress(task_id,j) <= task_data.requirements[j].require{
						complete_count++
					}
				}
				//不携带特定种类卡片类任务
				if task_data.requirements[j].type == "card_type_limit"{
					var limit_card_list = struct_get(card_group,task_data.requirements[j].limit_card_type)
					//遍历卡组，如果没找到相关卡片，则没有携带
					not_use_designated_card = true
					for(var k = 0 ; k < ds_list_size(global.selected_deck) ; k++){
						if array_get_index(limit_card_list,global.selected_deck[| k][? "card_id"]) != -1{
							not_use_designated_card = false
						}
					}
					//如果没有携带指定卡片，则增加进度
					if not_use_designated_card{
						add_task_progress(task_id,j,1)
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
				//解锁下一个任务
				if !is_task_unlocked(task_data.task_unlock){
					unlock_task(task_data.task_unlock)
				}
			}
			//如果是单局完成的任务，未完成则重置进度
			else if task_data.single_game{
				for(var j = 0 ; j < array_length(global.save_data.tasks[i].progress) ; j++){ 
					edit_task_progress(task_id,j,0)
				}
			}
		}
	}
}