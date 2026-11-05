/// @function enemy_is_boss(_enemy_id)
/// @desc 判断某个已注册敌人是不是 BOSS。
///       依据 register_enemy 的描述约定：BOSS 条目的 description 一律写成「XXX：XX岛BOSS」
///       （脚本化校验过 37 条 BOSS / 120 条普通鼠军，无遗漏也无误判）。
///       如果以后改了这套描述文案，记得同步这里，否则只会影响图鉴里的缩放档位。
/// @param {String} _enemy_id 敌人 id（register_enemy 的键）
/// @returns {Bool}
function enemy_is_boss(_enemy_id)
{
	if (!ds_map_exists(global.enemy_map, _enemy_id)) return false;
	var _data = global.enemy_map[? _enemy_id];
	if (!is_struct(_data)) return false;
	return (string_pos("BOSS", _data.description) > 0);
}