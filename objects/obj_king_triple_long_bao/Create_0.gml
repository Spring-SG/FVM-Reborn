// obj_small_furnace 的 Create 事件
//plant_id = "small_fire";  // 唯一标识符
event_inherited();  // 继承父对象属性
plant_id = "king_triple_long_bao"; 
// 设置对象类型和精灵
obj_type = object_index;
sprite_index = spr_king_triple_long_bao_0_0;

current_level = 1
event_user(0)

// ========== 特定属性默认值 ==========

attack_anim = 7;
idle_anim = 11
flash_speed = 5
plant_type = "normal"
feature_type = "king_tbun"
is_slowdown = false
bun_count = 0
max_bun = 2

normal_spr_list = [spr_king_triple_long_bao_0_0,spr_king_triple_long_bao_0_1,spr_king_triple_long_bao_0_2]
upgrade_spr_list = [spr_king_triple_long_bao_0_upgrade_1,spr_king_triple_long_bao_0_upgrade_2]
if shape == 1{
	sprite_index = spr_king_triple_long_bao_1_0
	max_bun = 3
	normal_spr_list = [spr_king_triple_long_bao_1_0,spr_king_triple_long_bao_1_1,spr_king_triple_long_bao_1_2,spr_king_triple_long_bao_1_3]
	upgrade_spr_list = [spr_king_triple_long_bao_1_upgrade_1,spr_king_triple_long_bao_1_upgrade_2,spr_king_triple_long_bao_1_upgrade_3]
}
if shape == 2{
	sprite_index = spr_king_triple_long_bao_2_0
	max_bun = 5
	normal_spr_list = [spr_king_triple_long_bao_2_0,spr_king_triple_long_bao_2_1,spr_king_triple_long_bao_2_2,spr_king_triple_long_bao_2_3,spr_king_triple_long_bao_2_4,spr_king_triple_long_bao_2_5]
	upgrade_spr_list = [spr_king_triple_long_bao_2_upgrade_1,spr_king_triple_long_bao_2_upgrade_2,spr_king_triple_long_bao_2_upgrade_3,spr_king_triple_long_bao_2_upgrade_4,spr_king_triple_long_bao_2_upgrade_5]
}
upgrade_timer = 0

//定义各个包子类卡片提供的子弹属性
bun_card_info = [
	{
		"card_id":"triple_long_bao",
		"bun_amount":1,
		"bullet_type":obj_xiaolongbao_bullet
	},
	{
		"card_id":"triple_ice_long_bao",
		"bun_amount":1,
		"bullet_type":obj_icelongbao_bullet
	},
	{
		"card_id":"king_triple_long_bao",
		"bun_amount":1,
		"bullet_type":obj_xiaolongbao_bullet
	}
]
//定义初始子弹槽
bullet_list = [
	{
		"bullet_type":obj_xiaolongbao_bullet,
		"damage":atk
	}
]