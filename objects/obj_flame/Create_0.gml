value = 25
disappear_timer = 0
image_speed = 1
image_xscale = 1.6
image_yscale = 1.6
// CREATE 事件
lifespan = 600;
fade_duration = 30;

is_collected = false;
is_capture = false
collect_timer = 0;
collect_duration = 30;
start_x = x;
start_y = y;
target_x = 420;
target_y = 70;
ease_type = 2;

collision_radius = 50;

// 自动收集相关
auto_collect_timer = 0;
will_auto_collect = false;

// 物理属性（新增）
mode = 1;                // 0=自然生成(天上), 1=植物生产
is_landed = false;       // 是否已落地
gravity = 0.5;           // 重力加速度
velocity_x = 0;          // X轴速度
velocity_y = 0;          // Y轴速度
ground_level = 500;      // 地面高度

// 根据生成模式初始化物理状态
if (mode == 0) {
    // 自然生成模式（从天而降）
    is_landed = false;
    // 设置随机目标位置（种植区域）
    var target_area_x1 = 750;
    var target_area_x2 = 1600;
    var target_area_y1 = 250;
    var target_area_y2 = 700;
    
    x = random_range(target_area_x1, target_area_x2);
    ground_level = random_range(target_area_y1, target_area_y2);
    
    // 初始位置在目标位置正上方
    //x = target_x;
   // y = -50;
    
    // 匀速下降
	gravity = 0
    velocity_y = 3;
} else {
    // 植物生产模式
    is_landed = false;
    var target_area_x1 = 750;
    var target_area_x2 = 1600;
    var target_area_y1 = 250;
    var target_area_y2 = 700;
    
    x1 = random_range(target_area_x1, target_area_x2);
    ground_level1 = random_range(target_area_y1, target_area_y2);
    // 随机初始速度（向上弹射）
    vspeed = random_range(-8, -12); // 向上速度
    hspeed = random_range(-2, 2);   // 随机水平速度
	ground_level = y + 50;
}