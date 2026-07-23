///@desc 初始化变量
event_inherited();

mouse_id = "mouse_train_1"
jump_times = 0
skill_timer = 0
state = BOSS_STATE.APPEAR
hp = 200000
maxhp = 200000
immune_to_ash = true
wait_time = 120
move_time = 250
cave = noone
sprite_index = spr_mouse_train_1_head_idle
is_boss = true

skill_choose = 0
skill_count = 0
image_alpha = 0
appear = false
avaliable_pos = ds_list_create()
missle_coord = []

skill_change_style = 0

x_move_speed = 0
y_move_speed = 0

hpbar_inst = instance_create_depth(450,1040,-900,obj_boss_hpbar)
hpbar_inst.target_boss = id
hpbar_inst.boss_id = mouse_id

train_body_list = []
is_reversed = false

if obj_battle.boss_count > 0{
	hpbar_inst.y -= 40
}

///@desc 按方向创建新的车厢
function create_train_body(amount,dir){
	if global.network.mode=="client"{
		exit
	}
	for(var i = 0 ; i < amount ; i++){
		if dir == 0{
			var inst = instance_create_depth(x,y+228*(i+1),depth,obj_mouse_train_1_body)
			inst.train_head = id
			inst.state = BOSS_STATE.APPEAR
			inst.skill_choose = skill_choose
			inst.skill_change_style = skill_change_style
			inst.move_time = move_time
			inst.maxhp = maxhp
			inst.hp = inst.maxhp
			inst.hp_modified = true
			array_push(train_body_list,inst)
		}
		else{
			var inst = instance_create_depth(x,y-228*(i+1),depth,obj_mouse_train_1_body)
			inst.train_head = id
			inst.state = BOSS_STATE.APPEAR
			inst.image_angle = 180
			inst.skill_choose = skill_choose
			inst.skill_change_style = skill_change_style
			inst.move_time = move_time
			inst.maxhp = maxhp
			inst.hp = inst.maxhp
			inst.hp_modified = true
			array_push(train_body_list,inst)
		}
	}
}

///@desc 移除指定位置的车厢
function remove_train_body(index){
	if global.network.mode=="client"{
		exit
	}
	if instance_exists(train_body_list[index]){
		instance_destroy(train_body_list[index])
		array_delete(train_body_list,index,1)
	}
}

///@desc 移除所有车厢
function clear_train_body(){
	if global.network.mode=="client"{
		exit
	}
	for(var i = 0 ; i < array_length(train_body_list) ; i++){
		if instance_exists(train_body_list[i]){
			instance_destroy(train_body_list[i])
		}
	}
	train_body_list = []
}
