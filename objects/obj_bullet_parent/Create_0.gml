/// obj_bullet_parent :: Create
/// 子弹基类。子对象写法：先 event_inherited()，再覆盖差异项
///（缩放、碰撞开关、bullet_xxx 行为钩子）。

// ===== 通用状态 =====
damage       = 0;       // 伤害
move_speed   = 0;       // 移动速度（像素/帧）
row          = 0;       // 当前所在行
damage_type  = "normal";
target_type  = "normal";
timer        = 0;
burnt        = 0;       // 0=普通 1=焦 2=着火
bounced      = false;   // 是否已被布丁弹回
atk_modified = false;   // 果挞卡加成是否已结算

// ===== 缩放与动画 =====
image_xscale = 1.8;
image_yscale = 1.8;
image_speed  = 0;
bullet_anim_manual = false;  // true: 由 Step 按 bullet_anim_step 手动推帧
bullet_anim_step   = 3;

// ===== 碰撞开关（子对象按需打开）=====
bullet_collides_enemy    = true;
bullet_collides_obstacle = false;
bullet_collides_brazier  = false;
bullet_collides_bounce   = false;

// ===== 焦 / 着火参数 =====
burnt_fire_level         = 1;   // burnt >= 该值，命中敌人时播燃烧音效
bullet_max_burn          = 1;   // 火盆最多点燃次数
bullet_burn_damage_level = 1;   // burnt >= 该值才结算火盆加成

// ===== 果挞卡加成 =====
bullet_uses_atk_bonus = false;

// 火盆点亮记录，Destroy 统一释放
brazier_list = ds_list_create();

// ==================== 可重写行为 ====================

/// @function bullet_update()
/// @description 每帧推进（移动/追踪/抛物线），默认水平飞行
bullet_update = function() {
	x += move_speed;
};

/// @function bullet_update_sprite()
/// @description 燃烧换图，默认 burnt==1 换成火焰弹
bullet_update_sprite = function() {
	if (burnt == 1) sprite_index = spr_fire_bullet;
};

/// @function bullet_out_of_bounds()
/// @description 出界判定，投掷类子对象会重写成 -200 余量
bullet_out_of_bounds = function() {
	return (x > 2200 || y > 1200 || x < 0 || y < 0);
};

/// @function bullet_enemy_row_ok(_enemy)
/// @description 是否命中同一行，纵向子弹重写
bullet_enemy_row_ok = function(_enemy) {
	return (row == _enemy.grid_row);
};

/// @function bullet_can_hit_enemy(_enemy)
/// @description 命中敌人的统一前置判定
bullet_can_hit_enemy = function(_enemy) {
	return (_enemy.hp > 0)
		&& bullet_enemy_row_ok(_enemy)
		&& can_hit(target_type, _enemy.target_type);
};

/// @function bullet_play_hit_sound(_enemy)
/// @description 命中音效；hit_sound 是敌人对象上的变量，必须取敌人自己的
bullet_play_hit_sound = function(_enemy) {
	if (burnt >= burnt_fire_level) {
		global.audio.play(snd_fire_hit, 0, 0);
	} else {
		global.audio.play(_enemy.hit_sound, 0, 0);
	}
};

/// @function bullet_on_hit_status(_enemy)
/// @description 伤害结算前的附加状态（冰冻等），子对象重写
bullet_on_hit_status = function(_enemy) {};

/// @function bullet_damage_enemy(_enemy)
/// @description 统一伤害结算：音效 -> 附加状态 -> 扣血
bullet_damage_enemy = function(_enemy) {
	bullet_play_hit_sound(_enemy);
	bullet_on_hit_status(_enemy);
	_enemy.damage_amount = damage;
	_enemy.damage_type   = damage_type;
	with (_enemy) {
		event_user(0);
	}
};

/// @function bullet_on_hit_effect()
/// @description 命中特效，子对象重写（默认无）
bullet_on_hit_effect = function() {};

/// @function bullet_on_hit_enemy(_enemy)
/// @description 命中敌人后的收尾，默认播特效并销毁
bullet_on_hit_enemy = function(_enemy) {
	bullet_on_hit_effect();
	instance_destroy();
};

/// @function bullet_obstacle_row_ok(_obstacle)
bullet_obstacle_row_ok = function(_obstacle) {
	return (row == _obstacle.row);
};

/// @function bullet_on_hit_obstacle(_obstacle)
bullet_on_hit_obstacle = function(_obstacle) {
	bullet_on_hit_effect();
	instance_destroy();
};

/// @function bullet_brazier_row_ok(_brazier)
bullet_brazier_row_ok = function(_brazier) {
	return (row == _brazier.grid_row);
};

/// @function bullet_on_burnt()
/// @description 被火盆点燃后的附加表现，子对象重写
bullet_on_burnt = function() {};

/// @function bullet_bounce_row_ok(_pudding)
bullet_bounce_row_ok = function(_pudding) {
	return (row == _pudding.grid_row);
};

/// @function bullet_on_bounce()
/// @description 被布丁弹回后的附加表现，子对象重写
bullet_on_bounce = function() {};

/// @function bullet_atk_bonus_multiplier(_atk)
/// @description 果挞卡加成的伤害倍率，子对象按需重写（如生煎包按半衰折算）
bullet_atk_bonus_multiplier = function(_atk) {
	return _atk;
};

/// @function bullet_apply_atk_bonus()
/// @description 果挞卡（fruit_tart）伤害加成；作用范围只在这里判定
bullet_apply_atk_bonus = function() {
	with (obj_card_parent) {
		if (plant_id == "fruit_tart") {
			if ((grid_row == other.row && ((shape <= 0 && x >= other.x) || shape == 1)) || (abs(grid_row - other.row) <= 1 && shape >= 2)) {
				other.damage *= other.bullet_atk_bonus_multiplier(atk);
				other.atk_modified = true;
			}
		}
	}
};

/// @function bullet_pult_redirect(_target, _flight_time, _height)
/// @description 投掷弹命中主目标后重算抛物线，飞向目标后一格
bullet_pult_redirect = function(_target, _flight_time = 30, _height = 300) {
	var _distance_x = _target.x + global.grid_cell_size_x;
	var _total_x    = _distance_x - x;
	move_speed = _total_x / _flight_time;
	cgravity   = (2 * _height) / (_flight_time * _flight_time);
	cvspeed    = (_height - 0 * cgravity * _flight_time * _flight_time) / _flight_time;
};

/// @function bullet_create_effect(_object, _sprite, _offset_x)
/// @description 生成命中特效，_sprite 传 -1 表示沿用对象自带精灵
bullet_create_effect = function(_object, _sprite = -1, _offset_x = 0) {
	var _inst = instance_create_depth(x + _offset_x, y, depth, _object);
	if (_sprite != -1) _inst.sprite_index = _sprite;
	return _inst;
};

/// @function bullet_create_fire_effect()
/// @description 生成"燃烧弹"命中特效
bullet_create_fire_effect = function() {
	return bullet_create_effect(obj_fire_bullet_effect, spr_fire_bullet_effect, 25);
};