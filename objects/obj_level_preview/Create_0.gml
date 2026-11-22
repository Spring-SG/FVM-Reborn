enemy_type_list = []
boss_type_list = []

mouse_preview_inst = []

// ── 普通敌人分页 ───────────────────────────────────────────────────
// 一个关卡最多 54 种普通敌人，一屏放不下；按 10 列 × 3 行 = 30 个/页分页，
// 滚轮上下翻页。BOSS 行不再固定 y，而是贴在当前页普通敌人所占行数的下方。
preview_cols  = 10      // 每行几个
preview_rows  = 3       // 每页几行（每页 preview_cols * preview_rows 个）
preview_page  = 0       // 当前页（0 起）
preview_pages = 1       // 总页数，Step 里算
preview_dirty = true    // 需要重建预览实例（换页 / 首次进入）

// ── 布局（Draw_0 画 BOSS 标签时也要读）──────────────────────────────
boss_row_y   = 900      // BOSS 行底边 y，随当前页正常敌人行数变化
boss_label_y = 820      // "BOSS" 文字的 y，跟着 boss_row_y 走

/// @function level_hp_rate()
/// @desc 本关卡普通敌人的血量倍率（= [关卡文件] hp_modify）。
///       1.1.0 等旧格式关卡没有这个字段，运行时也不乘，这里同样按 1 处理。
level_hp_rate = function()
{
	if (!variable_struct_exists(global.level_file, "hp_modify")) return 1;
	var _r = global.level_file.hp_modify;
	if (!is_real(_r)) return 1;
	return _r;
}

/// @function level_boss_hp_rate(_boss_id)
/// @desc 某个 BOSS 在本关卡里的血量倍率：扫所有波次，找 boss / boss2 正好是它的那条，
///       取对应的 boss_1_hp_modify / boss_2_hp_modify。找不到（或旧格式）按 1 处理。
level_boss_hp_rate = function(_boss_id)
{
	if (!variable_struct_exists(global.level_file, "waves")) return 1;
	var _waves = global.level_file.waves;
	for (var i = 0; i < array_length(_waves); i++){
		var _w = _waves[i];
		if (!is_struct(_w)) continue;
		if (variable_struct_exists(_w, "boss") && _w[$ "boss"] == _boss_id
			&& variable_struct_exists(_w, "boss_1_hp_modify") && is_real(_w[$ "boss_1_hp_modify"])){
			return _w[$ "boss_1_hp_modify"];
		}
		if (variable_struct_exists(_w, "boss2") && _w[$ "boss2"] == _boss_id
			&& variable_struct_exists(_w, "boss_2_hp_modify") && is_real(_w[$ "boss_2_hp_modify"])){
			return _w[$ "boss_2_hp_modify"];
		}
	}
	return 1;
}

/// @function hp_line(_label, _base, _rate)
/// @desc 拼一行血量文本：显示乘完倍率的实际血量，倍率不是 1 时附注「（×倍率）」
hp_line = function(_label, _base, _rate)
{
	var _value = string(round(_base * _rate));
	if (abs(_rate - 1) > 0.001){
		_value += "（×" + string(_rate) + "）";
	}
	return _label + _value;
}
