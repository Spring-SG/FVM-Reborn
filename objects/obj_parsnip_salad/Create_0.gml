// obj_small_furnace 的 Create 事件
//plant_id = "small_fire";  // 唯一标识符
event_inherited();  // 继承父对象属性
plant_id = "parsnip_salad"; 
// 设置对象类型和精灵

event_user(0)
sprite_index = spr_parsnip_salad;
if shape == 1{
	sprite_index = spr_parsnip_salad_1
}
// ========== 特定属性默认值 ==========
attack_anim = 13;
idle_anim = 12
flash_speed = 5
plant_type = "normal"
is_slowdown = false

heal_wait = 0
current_hp = 0
bleed_damage = 0

hp_increase_card_list = []
maxhp_increase_card_list = []