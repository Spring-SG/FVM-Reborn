/// 披萨炉子弹：飞到 target_x 后转为原地扫射，伤害由 Step 内 place_meeting 判定
event_inherited();

damage_type = "air";
target_type = "air";
target_x = 0;
target_enemy = noone;
state = "move";

// 不用通用碰撞流程，避免和 Step 内的范围判定重复结算
bullet_collides_enemy = false;