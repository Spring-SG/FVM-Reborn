if global.is_paused{
	exit
}
x += move_speed
y -= cvspeed
cvspeed -= cgravity
image_angle -= 5
if x > 2200 or y > 1200 or x < -200 or y < -200{
	instance_destroy()
}
// 检查是否命中目标敌人
//if target_enemy != noone && instance_exists(target_enemy) && target_enemy.hp > 0{
//    if hit_enemy {
//        // 命中主要目标
        
//        // 弹射到敌人身后一格位置
//        var splash_x = target_enemy.x + global.grid_cell_size_x
//        var splash_y = target_enemy.y
        
//        // 计算弹射轨迹（简单的直线运动）
//        var dist = point_distance(x, y, splash_x, splash_y)
        
//        if dist <= 10 or y >= thrower_y {
//            // 到达溅射点，造成溅射伤害
//            instance_create_depth(x,y,depth,obj_eggboilerpult_bullet_effect)
//            instance_destroy()
//        }
//    }
//} else 
if target_enemy != noone && (!instance_exists(target_enemy) or target_enemy.hp <= 0){
    // 目标敌人在飞行过程中死亡，检查是否落地
    if y >= thrower_y {
        // 击中地面，造成溅射伤害
        var inst = instance_create_depth(x,y,depth,obj_coke_bomb_explode)
		inst.sprite_index = spr_sugar_ball_pult_bullet_effect
		instance_destroy()
    }
}