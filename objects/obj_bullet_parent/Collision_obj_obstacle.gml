/// 撞到障碍物：只有普通子弹会被挡下
if (!bullet_collides_obstacle) exit;
if (target_type != "normal") exit;
if (!bullet_obstacle_row_ok(other)) exit;

bullet_on_hit_obstacle(other);