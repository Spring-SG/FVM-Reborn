// 场景切换遮罩：Post-Draw（8,73）——在所有 depth 图层与 Draw GUI 之后，战斗房的血条也盖得住
var _a = room_transition_alpha()
if _a <= 0 exit

draw_set_alpha(_a)
draw_rectangle_color(0, 0, room_width, room_height, global.room_trans.color, global.room_trans.color, global.room_trans.color, global.room_trans.color, false)
draw_set_alpha(1)
