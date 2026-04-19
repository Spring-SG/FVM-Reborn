// 平台的基本网格属性
start_col = 0;          // 起始列
start_row = 0;          // 起始行
width = 1;              // 宽度（占多少列）
length = 1;             // 长度（占多少行）

// 移动逻辑属性
move_axis = "y";        // 移动所在轴："x" 横向 或 "y" 纵向
move_distance = 2;      // 总位移格数（2格）
current_offset = 0;     // 当前已位移格数（0 表示在起点）
move_direction = 1;     // 1 为向下(y)/向右(x)，-1 为向上/向左
state = "idle";         // "idle" 等待状态, "moving" 移动状态

// 动画与速度
idle_timer = 0;
idle_duration = 300;    // 停顿时间（比如5秒=300帧）
move_progress = 0;      // 当前向下一格移动的进度 (0.0 到 1.0)
move_speed = 0.01;      // 每帧移动进度（0.01 表示 100帧走完1格）

// 标志位
first_frame = true;     // 用于在第一帧初始化网格地形

// 视觉位移偏差记录，供预览和放置逻辑读取
visual_x_shift = 0;
visual_y_shift = 0;

// 深度设定：确保踩在地板或水面上方，所有的植物下面
depth = -5;
