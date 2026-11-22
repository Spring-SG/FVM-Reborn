/// 被樱桃布丁弹回：每颗子弹只反弹一次
if (!bullet_collides_bounce) exit;
if (bounced) exit;
if (!bullet_bounce_row_ok(other)) exit;

move_speed *= -1;
damage += other.atk;
image_angle += 180;
bounced = true;
bullet_on_bounce();