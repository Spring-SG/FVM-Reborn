// STEP 事件
if global.is_paused{
	x -= hspeed
	y -= vspeed
	vspeed -= gravity
	exit
}
if !is_capture{
	// 只在落地后开始消失计时
	if (is_landed && !is_collected) {
	    if (disappear_timer < lifespan) {
	        disappear_timer++;
	    } else if (disappear_timer < lifespan + fade_duration) {
	        image_alpha = 1 - ((disappear_timer - lifespan) / fade_duration);
	        disappear_timer++;
	    } else {
	        instance_destroy();
	    }
	}

	// 物理运动（仅在未落地时）
	if (!is_landed) {
	    // 应用重力（仅对植物生产的阳光）
	    if (mode == 1) {
	        //velocity_y += gravity;
			gravity = 0.5
			velocity_x = 0
			velocity_y = 0
	    }
		else {
			gravity = 0
			hspeed = 0
			vspeed = 0
			velocity_y = 3
			ground_level = ground_level1
			x = x1
		}
    
	    // 更新位置
	    x += velocity_x;
	    y += velocity_y;
    
	    // 检查是否落地
    
	}

	// 自动收集计时（只在落地后开始）
	if (is_landed && global.auto_collect && !is_collected && !will_auto_collect) {
	    auto_collect_timer++;
	    if (auto_collect_timer >= global.auto_collect_delay) {
	        will_auto_collect = true;
	        //instance_create_layer(x, y, "Effects", obj_auto_collect_fx);
	    }
	}

	// 检测收集（无论是否落地）
	if (!is_collected) {
	    var mx = mouse_x;
	    var my = mouse_y;
	    var mouse_over = point_distance(x, y, mx, my) < collision_radius;
    
	    if (mouse_over || will_auto_collect) {
	        is_collected = true;
	        collect_timer = 0;
	        start_x = x;
	        start_y = y;
	        audio_play_sound(snd_flame_collect, 1, false);
	    }
	}

	// 收集动画
	if (is_collected) {
	    collect_timer++;
	    var t = collect_timer / collect_duration;
    
	    // 缓动函数
	    if (ease_type == 2) {
	        t = 1 - (1 - t) * (1 - t);
	    }
    
	    x = start_x + (target_x - start_x) * t;
	    y = start_y + (target_y - start_y) * t;
    
    
    
	    if (collect_timer >= collect_duration) {
	        global.flame += value;
	        //var fx = instance_create_layer(target_x, target_y, "Effects", obj_sun_fx);
	       // fx.value = value;
	        instance_destroy();
	    }
	}
}