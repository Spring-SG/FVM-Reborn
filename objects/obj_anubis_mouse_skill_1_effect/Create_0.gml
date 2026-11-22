// 阿努比斯鼠技能1：3*3 睡眠领域
// 贴图有效内容约 212x216，1.5 倍后约 318x324，正好覆盖 3*3 格子（321x348）
image_xscale = 1.8
image_yscale = 1.8
image_alpha = 1
timer = 0
life_time = 25 * 60          // 30 秒（60 帧/秒）
grid_row = 0
grid_col = 0
slept_card_id_list = []      // 被本领域睡过的卡片，到期时统一复原
