/// 命中敌人：通用流程（判定 -> 结算伤害 -> 收尾）
if (!bullet_collides_enemy) exit;
if (!bullet_can_hit_enemy(other)) exit;

bullet_damage_enemy(other);
bullet_on_hit_enemy(other);