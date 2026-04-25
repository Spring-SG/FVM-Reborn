// 强制清除application_surface，避免上一房间图像残留
surface_set_target(application_surface);
draw_clear_alpha(c_black, 0); // 用透明黑色清除surface，alpha值0表示完全透明
surface_reset_target();

depth = 50

instance_create_depth(0,0,-900,obj_flame_manager)
instance_create_depth(0,0,0,obj_event_manager)
//instance_create_depth(450,1040,-900,obj_boss_hpbar)
var mus_inst = instance_create_depth(0,0,0,obj_battle_music_controller)
mus_inst.battle_music = global.level_data.pre_music

global.game_over = false

instance_create_depth(0,0,0,obj_battle_pause_manager)
instance_create_depth(0,0,-2900,obj_battle_timer_display)
instance_create_depth(mouse_x,mouse_y,0,obj_player_character)

instance_create_depth(room_width-200,room_height-25,0,obj_level_progress_bar)


global.selected_slot = noone;
global.current_seed = noone;
global.grid_offset_x = 695
global.grid_cell_size_x = 107
global.grid_cell_size_y = 116
global.grid_offset_y = 228
global.grid_cols = global.level_file.map_cols
global.grid_rows = global.level_file.map_rows


//啃食音效
chomp_sound_list = ds_list_create()
battle_time = 0
boss_count = 0
map_spr_index = 0

speed_up = false
time_limit = -1
timer_pause = false

ds_list_add(chomp_sound_list,snd_chomp1)
ds_list_add(chomp_sound_list,snd_chomp2)
ds_list_add(chomp_sound_list,snd_chomp3)
// 植物层级定义
global.plant_layers = ds_map_create();
ds_map_add(global.plant_layers, "normal", 0);      // 普通植物
ds_map_add(global.plant_layers, "shield_inner", 1);      // 护罩植物内侧
ds_map_add(global.plant_layers, "lilypad", 2);     // 莲叶花盆类
ds_map_add(global.plant_layers, "shield_outer", 3);      // 护罩植物外侧
ds_map_add(global.plant_layers, "coffee", 4);      // 咖啡豆类

// 铲除顺序
global.shovel_order = ds_list_create();
ds_list_add(global.shovel_order,"normal", "shield","shield_outer", "lilypad","coffee");
global.eat_order = ds_list_create();
ds_list_add(global.eat_order,"shield","shield_outer","normal","lilypad");

// 网格植物存储数据结构
global.grid_plants = ds_grid_create(global.grid_cols, global.grid_rows);

//重置任务进度
with obj_task_manager{
	reset_task_state()
}

// 初始化网格
for (var col = 0; col < global.grid_cols; col++) {
    for (var row = 0; row < global.grid_rows; row++) {
        // 每个网格存储一个 ds_list，包含该网格的所有植物实例
        var plant_list = ds_list_create();
        ds_grid_set(global.grid_plants, col, row, plant_list);
    }
}

var plant_list = global.level_file.map
global.grid_terrains = global.level_file.map
global.row_feature = []
for(var i = 0 ; i < global.grid_rows;i++){
	if global.grid_terrains[i][0].type == "water"{
		global.row_feature[i] = "water"
	}
	else{
		global.row_feature[i] = "land"
	}
}
for(var i = 0 ; i < global.grid_rows ; i++){
	for(var j = 0 ; j < global.grid_cols ; j ++){
		var cards = plant_list[i][j].plant
		if array_length(cards) > 0{
			for(var k = 0; k < array_length(cards);k++){
				var card_data = deck_get_card_data(cards[k],0)
				var card_obj = card_data[? "obj"]
				var new_x = global.grid_offset_x + j * global.grid_cell_size_x
				var new_y = global.grid_offset_y + i * global.grid_cell_size_y
				var grid_pos = get_grid_position_from_world(new_x,new_y)
				var new_plant = instance_create_depth(grid_pos.x, grid_pos.y, 0,card_obj);
				var depth_value = calculate_plant_depth(j, i, new_plant.plant_type);
				card_created(new_plant, j, i);
				new_plant.depth = depth_value
			}
			
		}
		var map_objs = plant_list[i][j].object
		if array_length(map_objs) > 0{
			for(var k = 0; k < array_length(map_objs);k++){
				var map_obj_data = get_map_object_data(map_objs[k])
				var map_obj = map_obj_data._obj
				var grid_pos = get_world_position_from_grid(j,i)
				var new_x = grid_pos.x + map_obj_data.x_offset
				var new_y = grid_pos.y + map_obj_data.y_offset
				
				var new_obj = instance_create_depth(new_x, new_y, -1200,map_obj);
				new_obj.row = i
				new_obj.col = j
			}
			
		}
	}
	var new_x = global.grid_offset_x -1 * global.grid_cell_size_x
	var new_y = global.grid_offset_y + i * global.grid_cell_size_y
	var grid_pos = get_grid_position_from_world(new_x,new_y)
	var cat_inst = instance_create_depth(grid_pos.x - 10, grid_pos.y+10, 0,obj_cat);
	cat_inst.row = i
	if global.row_feature[i] == "water"{
		cat_inst.sprite_index = spr_crab
		cat_inst.idle_anim = 8
		cat_inst.awake_anim = 6
		cat_inst.attack_anim = 9
	}
}

//关卡波次
current_wave = 0
current_subwave = 0
total_wave = global.level_file.total_waves
level_stage = "ready"
current_total_hp = 0
current_wave_hp = 0
hp_ratio = 0.2
if global.difficulty >= 2{
	hp_ratio = 0.5
}
enemy_list = []

wave_max_time = 25*60
wave_min_time = 4 * 60
wave_timer = 0
//根据难度调整最大波长
if global.difficulty >= 3 && global.map_id != "tower_cake"{
	wave_max_time = 12.5*60
}
if is_real(global.level_file.version){
	wave_max_time = global.level_file.max_wave_time
	wave_min_time = global.level_file.min_wave_time
	if global.difficulty >= 3 && global.map_id != "tower_cake"{
		wave_max_time = round(wave_max_time/2)
	}
}

global.prev_place_id = ""

function enemy_subwave_summon(){
	current_total_hp = 0
	
    wave_timer = wave_max_time
	
	if level_stage == "boss"{
		wave_timer = 10 * 60
	}
	
	if is_real(global.level_file.version){
		if global.level_file.version >= 1.3{
			if current_wave < total_wave{
				if global.level_file.waves[current_wave].subwaves[current_subwave].local_max_wave_time >0{
					wave_timer = global.level_file.waves[current_wave].subwaves[current_subwave].local_max_wave_time
				}
			}
		}
	}
    
    var subwave_enemy = global.level_file.waves[current_wave].subwaves
    enemy_list = subwave_enemy[current_subwave].enemy_list
    
    // 第一阶段：先处理已有行数的敌人
    var row_enemy_count = array_create(global.grid_rows, 0); // 记录每行已有敌人数
    
    // 先统计已有行数的敌人
    for (var i = 0; i < array_length(enemy_list); i++) {
        if (enemy_list[i].type != "" && enemy_list[i].row > 0) {
            var row_index = enemy_list[i].row - 1;
            if (row_index >= 0 && row_index < global.grid_rows) {
                //row_enemy_count[row_index]++;
            }
        }
    }
    
    // 创建已使用的行数组（用于第二阶段）
    var rows_used = array_create(global.grid_rows, false);
    
    // 第二阶段：创建敌人实例
    for (var i = 0; i < array_length(enemy_list); i++) {
        if (enemy_list[i].type != "") {
            var target_row = enemy_list[i].row;
            var x_offset = 0;
            
            // 获取敌人的特性（陆地或水上）
            var enemy_feature = global.enemy_map[? enemy_list[i].type].feature;
            
            // 情况1：已有行数的敌人
            if (target_row > 0 && target_row <= global.grid_rows) {
                // 检查该行是否适合这种敌人
                var row_index = target_row - 1;
                var row_type = global.row_feature[row_index];
                
                // 如果行类型与敌人特性不匹配，则需要重新分配
                if ((enemy_feature == "land" && row_type != "land") || 
                    (enemy_feature == "water" && row_type != "water")) {
                    // 标记为需要重新分配行数
                    target_row = 0;
                } else {
                    // 保留原有行数
                    x_offset = row_enemy_count[row_index]; // 使用该行已有的敌人数作为偏移
                    rows_used[row_index] = true; // 标记该行已使用
                }
            }
            
            // 情况2：需要随机分配行数的敌人（包括不匹配的情况）
            if (target_row <= 0 || target_row > global.grid_rows) {
                // 根据敌人特性筛选合适的行
                var available_rows = [];
                for (var r = 0; r < global.grid_rows; r++) {
                    var row_type = global.row_feature[r];
                    
                    // 检查行类型是否匹配敌人特性
                    var row_matches = false;
                    if (enemy_feature == "land" && row_type == "land") {
                        row_matches = true;
                    } else if (enemy_feature == "water" && row_type == "water") {
                        row_matches = true;
                    }
                    
                    // 如果行类型匹配，并且该行未被使用，则加入可用行列表
                    if (row_matches && !rows_used[r]) {
                        array_push(available_rows, r + 1); // 存储行号（1-based）
                    }
                }
                
                // 如果还有未使用的匹配行
                if (array_length(available_rows) > 0) {
                    // 随机选择一个未使用的匹配行
                    target_row = available_rows[irandom(array_length(available_rows) - 1)];
                } else {
                    // 所有匹配行都已使用，从所有匹配行中随机选择
                    var all_matching_rows = [];
                    for (var r = 0; r < global.grid_rows; r++) {
                        var row_type = global.row_feature[r];
                        
                        var row_matches = false;
                        if (enemy_feature == "land" && row_type == "land") {
                            row_matches = true;
                        } else if (enemy_feature == "water" && row_type == "water") {
                            row_matches = true;
                        }
                        
                        if (row_matches) {
                            array_push(all_matching_rows, r + 1);
                        }
                    }
                    
                    if (array_length(all_matching_rows) > 0) {
                        target_row = all_matching_rows[irandom(array_length(all_matching_rows) - 1)];
                    } else {
                        // 如果没有匹配的行，发出警告并选择第一行（或者你可以处理这个错误）
                        show_debug_message("错误：没有适合" + enemy_feature + "敌人的行！");
                        target_row = 1;
                    }
                }
                
                // 更新敌人的行属性
                enemy_list[i].row = target_row;
                var row_index = target_row - 1;
                x_offset = row_enemy_count[row_index]; // 使用该行已有的敌人数作为偏移
                rows_used[row_index] = true; // 标记该行已使用
            }
            
            // 创建敌人实例
            var enemy_obj = global.enemy_map[? enemy_list[i].type]._obj;
            
            // 计算位置（考虑偏移）
            var new_x = global.grid_offset_x + (9 + x_offset) * global.grid_cell_size_x;
            var new_y = global.grid_offset_y + (target_row - 1) * global.grid_cell_size_y;
            
            var grid_pos = get_grid_position_from_world(new_x, new_y);
            var new_enemy = instance_create_depth(grid_pos.x+30, grid_pos.y + 38, 0, enemy_obj);
            
            // 更新统计信息
            current_total_hp += global.enemy_map[? enemy_list[i].type].hp;
            
            // 更新该行的敌人数
            var row_index = target_row - 1;
            row_enemy_count[row_index]++;
        }
    }
    
}