if (state) {
    image_index = 1; // 开启状态
} else {
    image_index = 0; // 关闭状态
}

// 切换瞬间的缩放回弹：1.0 → 峰值 → 1.0 的正弦包络
// 只改绘制缩放（image_xscale/yscale），不改 state、不改命中判定；包络始终 ≥1，不会缩小
// 基准缩放取回弹开始那一刻的值，回弹结束后原样还原（不覆盖别处对这些实例设过的缩放/镜像）
if (state != bounce_prev) {
    bounce_prev   = state;
    if (ui_anim_on(2)) {                 // 动效等级 <2：不做缩放回弹
        bounce_t      = 0;
        bounce_base_x = image_xscale;
        bounce_base_y = image_yscale;
    } else {
        bounce_t = -1;
    }
}
if (!ui_anim_on(2) && bounce_t >= 0) {   // 运行中把等级切到 <2：立刻收掉回弹
    bounce_t     = -1;
    image_xscale = bounce_base_x;
    image_yscale = bounce_base_y;
}
if (bounce_t >= 0) {
    bounce_t += 1;
    if (bounce_t >= bounce_frames) {
        bounce_t     = -1;
        image_xscale = bounce_base_x;
        image_yscale = bounce_base_y;
    } else {
        var _s = 1 + bounce_amount * sin(pi * bounce_t / bounce_frames);
        image_xscale = bounce_base_x * _s;
        image_yscale = bounce_base_y * _s;
    }
}