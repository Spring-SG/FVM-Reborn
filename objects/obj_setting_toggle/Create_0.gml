image_xscale = 1
image_yscale = 1

// 默认状态为关闭
state = false;
image_speed = 0; // 停止动画

// 配置键名（由创建者设置）
config_key = "";
tooltip_text = ""

// 切换回弹（纯绘制层：只改 image_xscale/yscale，不碰 state 与命中判定）
bounce_t      = -1;     // -1 = 未在回弹；>=0 = 回弹进行到第几帧
bounce_frames = 10;     // 回弹总时长（帧），60fps ≈ 0.17s
bounce_amount = 0.12;   // 峰值额外缩放
bounce_prev   = state;  // 上一帧的 state，用来检测切换
bounce_base_x = image_xscale;  // 回弹基准缩放（回弹开始时重新取一次，结束时还原）
bounce_base_y = image_yscale;