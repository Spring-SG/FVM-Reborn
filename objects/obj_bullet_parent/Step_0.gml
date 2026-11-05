/// obj_bullet_parent :: Step
/// 通用子弹帧循环：暂停 -> 推帧 -> 换图 -> 移动 -> 加成 -> 出界

if (global.is_paused) {
	image_speed = 0;
	exit;
}

// 推帧（自动 / 手动两套）
if (bullet_anim_manual) {
	image_speed = 0;
	timer++;
	image_index = (floor(timer / bullet_anim_step)) mod 4;
} else {
	image_speed = 1;
}

// 焦 / 着火换图
bullet_update_sprite();

// 移动（子对象按需重写）
bullet_update();

// 果挞卡加成
if (bullet_uses_atk_bonus && !atk_modified) bullet_apply_atk_bonus();

// 出界清理
if (bullet_out_of_bounds()) instance_destroy();