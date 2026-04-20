image_xscale = 2.8;
image_yscale = 2.8;

// 初始化变量
character_name = global.player_name; // 从全局变量获取当前角色名
selected_sprite = global.player_sprite; // 当前选择的形象
temp_sprite = selected_sprite; // 临时存储选择的形象（用于取消操作）

// 创建保存按钮
var save_btn = instance_create_depth(x - 250, y + 280, depth-1, obj_edit_menu_button);
save_btn.button_text = "保存";
save_btn.btn_type = "save";
save_btn.parent = id; // 设置父对象以便通信

// 创建保存按钮
var open_save_folder_btn = instance_create_depth(x, y + 280, depth-1, obj_edit_menu_button);
open_save_folder_btn.button_text = "存档文件夹";
open_save_folder_btn.btn_type = "open_save_folder";
open_save_folder_btn.parent = id; 


// 创建取消按钮
var cancel_btn = instance_create_depth(x + 250, y + 280, depth-1, obj_edit_menu_button);
cancel_btn.button_text = "取消";
cancel_btn.btn_type = "cancel";
cancel_btn.parent = id;

// 创建输入框
input_field = instance_create_depth(x-210, y - 190, depth-1, obj_text_input);
input_field.text = character_name;
input_field.max_length = 16;
input_field.placeholder = "输入角色名";
input_field.width = 300;
input_field.active = true;

var btn3 = instance_create_depth(x - 120, y -95 , depth-1, obj_save_slot_select_btn);
btn3.config_key = "save_slot";
btn3.state = global.save_slot;