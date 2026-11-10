/// obj_awaken_medusa_bullet :: Create
/// 觉醒美杜莎技能1 的穿透子弹：一直向左飞，命中卡片不消失，
/// 但每张卡片只会被同一颗子弹结算一次伤害（hit_list 记录）。

image_xscale = 1.8
image_yscale = 1.8
image_speed = 0

timer = 0
row = 0			// 所在行（0 基），只打同一行的卡片
damage = 50		// 对每张卡片的伤害
move_speed = 14	// 每帧左移像素
hit_list = []	// 已经结算过伤害的卡片实例，保证不重复输出