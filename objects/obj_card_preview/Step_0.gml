// obj_plant_preview STEP 事件
// 检查是否在可种植区域（需要根据您的游戏实现）
var logical_x = mouse_x;
var logical_y = mouse_y;
platform_shift_x = 0;
platform_shift_y = 0;

var plat = instance_position(mouse_x, mouse_y, obj_platform);
if (plat != noone) {
    platform_shift_x = plat.visual_x_shift;
    platform_shift_y = plat.visual_y_shift;
    logical_x -= platform_shift_x;
    logical_y -= platform_shift_y;
}

var grid_pos = get_grid_position_from_world(logical_x, logical_y);

 var card_shape = get_card_info_simple(card_id).shape
var card_data = deck_get_card_data(card_id,card_shape)
is_valid = (can_place_at_position(logical_x, logical_y, card_data[? "plant_type"],card_data[? "feature_type"],card_data[? "target_card"]));


// 跟随鼠标移动
x = mouse_x;
y = mouse_y;
logical_base_x = logical_x;
logical_base_y = logical_y;

// 如果父卡槽被取消，销毁自己
if (parent_slot == noone || !instance_exists(parent_slot) || !parent_slot.is_selected) {
    instance_destroy();
}