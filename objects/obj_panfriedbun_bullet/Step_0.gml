/// 生煎包投手子弹 Step：通用帧循环 + 落地留溅射源
event_inherited();
if (global.is_paused) exit;

if (y >= thrower_y) {
	var _gp = get_grid_position_from_world(x, y);
	bullet_pan_splash(_gp.x, _gp.y, _gp.row);
	instance_destroy();
}