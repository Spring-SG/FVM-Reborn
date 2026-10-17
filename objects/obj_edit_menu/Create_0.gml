image_xscale = 1;
image_yscale = 1;

// 初始化变量
character_name = global.player_name; // 从全局变量获取当前角色名
player_attire_id_list = get_card_attire_list("player")//获取玩家时装列表
selected_attire_id = card_equipped_attire_id("player")//获取玩家当前装备时装
selected_attire_index = -1 // 当前选择的时装索引
if selected_attire_id != -1{
	selected_attire_index = array_get_index(player_attire_id_list,selected_attire_id)
}

// 创建保存按钮
var save_btn = instance_create_depth(x - 350, y + 280, depth-1, obj_edit_menu_button);
save_btn.button_text = "保存";
save_btn.btn_type = "save";
save_btn.parent = id; // 设置父对象以便通信

// 创建保存按钮
var open_save_folder_btn = instance_create_depth(x - 175, y + 280, depth-1, obj_edit_menu_button);
open_save_folder_btn.button_text = "存档文件夹";
open_save_folder_btn.btn_type = "open_save_folder";
open_save_folder_btn.parent = id; 

// 创建导出按钮
var open_save_folder_btn = instance_create_depth(x, y + 280, depth-1, obj_edit_menu_button);
open_save_folder_btn.button_text = "备份全部存档";
open_save_folder_btn.btn_type = "export_save_backup";
open_save_folder_btn.parent = id; 

// 创建导入按钮
var open_save_folder_btn = instance_create_depth(x + 175, y + 280, depth-1, obj_edit_menu_button);
open_save_folder_btn.button_text = "还原备份";
open_save_folder_btn.btn_type = "import_save_backup";
open_save_folder_btn.parent = id; 

// 创建取消按钮
var cancel_btn = instance_create_depth(x + 350, y + 280, depth-1, obj_edit_menu_button);
cancel_btn.button_text = "取消";
cancel_btn.btn_type = "cancel";
cancel_btn.parent = id;

// 创建输入框
input_field = instance_create_depth(x-210, y - 195, depth-1, obj_text_input);
input_field.text = character_name;
input_field.max_length = 16;
input_field.placeholder = "输入角色名";
input_field.width = 300;
input_field.active = true;

for(var i = 0 ; i < 5 ; i++){
	var btn3 = instance_create_depth(x - 200+140*i, y -88 , depth-1, obj_save_slot_select_btn);
	btn3.config_key = "save_slot";
	btn3.state = i;
}

var btn4 = instance_create_depth(x-220,y+90,depth-1,obj_player_attire_select_btn)
btn4.type = "prev"

var btn5 = instance_create_depth(x+420,y+90,depth-1,obj_player_attire_select_btn)
btn5.type = "next"

var btn6 = instance_create_depth(x - 280, y +175 , depth-1, obj_update_checker_btn);