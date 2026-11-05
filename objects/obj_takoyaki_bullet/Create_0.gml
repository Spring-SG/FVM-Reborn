/// 章鱼烧子弹：归属式追踪弹，需要全局计数控制同屏数量
event_inherited();

target_type = "track";
target_enemy = noone;
banding_card_obj = noone;

if (!variable_global_exists("_takoyaki_buttet_number")) {
	global._takoyaki_buttet_number = 0;
}
global._takoyaki_buttet_number += 1;