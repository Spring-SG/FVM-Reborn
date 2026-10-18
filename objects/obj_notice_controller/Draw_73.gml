// 场景切换遮罩：Post-Draw（8,73）——在所有 depth 图层与 Draw GUI 之后，战斗房的血条也盖得住
var _a = room_transition_alpha()
if _a <= 0 exit

// 启动加载界面期间不画这层遮罩：进菜单房间的"淡入黑幕"会盖在加载画面上，
// 否则黑幕会盖在加载画面上，表现为美味镇背景闪一下黑。加载结束后 global.preloaded = true，
// 遮罩恢复正常（那时过渡早已跑完，不会突然跳出来一块黑）。
if (instance_exists(obj_menu_manager) && variable_global_exists("preloaded") && !global.preloaded) exit

draw_set_alpha(_a)
draw_rectangle_color(0, 0, room_width, room_height, global.room_trans.color, global.room_trans.color, global.room_trans.color, global.room_trans.color, false)
draw_set_alpha(1)
