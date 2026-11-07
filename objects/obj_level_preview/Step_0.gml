// ── 分页：普通敌人按 10 列 × 3 行 一页，滚轮翻页 ──────────────────
var _per_page = preview_cols * preview_rows;
var _total    = array_length(enemy_type_list);
preview_pages = max(1, ceil(_total / _per_page));
if (preview_page > preview_pages - 1) preview_page = preview_pages - 1;

if (preview_pages > 1){
	var _wheel = mouse_wheel_up() - mouse_wheel_down();   // 上滚 +1 / 下滚 -1
	if (_wheel != 0){
		var _new_page = clamp(preview_page - sign(_wheel), 0, preview_pages - 1);
		if (_new_page != preview_page){
			preview_page  = _new_page;
			preview_dirty = true;
		}
	}
}

// ── 重建预览实例（首次进入 / 换页）────────────────────────────────
if (preview_dirty){
	for (var i = 0; i < array_length(mouse_preview_inst); i++){
		if (instance_exists(mouse_preview_inst[i])) instance_destroy(mouse_preview_inst[i]);
	}
	mouse_preview_inst = [];
	
	var _rate  = level_hp_rate();
	var _start = preview_page * _per_page;
	var _end   = min(_start + _per_page, _total);
	var _count = max(0, _end - _start);
	
	// 本页普通敌人
	for (var i = 0; i < _count; i++){
		var _type = enemy_type_list[_start + i];
		var _data = global.enemy_map[? _type];
		var _inst = instance_create_depth(300 + (i mod preview_cols) * 170,
		                                  300 + floor(i / preview_cols) * 230,
		                                  depth-1, obj_mouse_preview);
		_inst.sprite_index = _data.spr;
		_inst.tooltip_text = _data.description + "\n" + hp_line("生命值：", _data.hp, _rate);
		if (_data.shield > 0){
			_inst.tooltip_text += "\n" + hp_line("防具血量：", _data.shield, _rate);
		}
		array_push(mouse_preview_inst, _inst);
	}
	
	// 普通敌人占了几行 → BOSS 行贴在这几行下面（不再固定 y）
	var _rows_used = (_count <= 0) ? 0 : ceil(_count / preview_cols);
	boss_row_y   = 300 + _rows_used * 230 + 40;
	boss_label_y = boss_row_y - 125;
	
	// BOSS 行：一格 340 宽，一屏最多放 5 个（实测关卡最多 5 种 BOSS）
	for (var i = 0; i < array_length(boss_type_list); i++){
		var _type = boss_type_list[i];
		var _data = global.enemy_map[? _type];
		var _brate = level_boss_hp_rate(_type);
		var _inst = instance_create_depth(300 + (i mod 5) * 340,
		                                  boss_row_y + floor(i / 5) * 280,
		                                  depth-1, obj_mouse_preview);
		_inst.sprite_index = _data.spr;
		_inst.tooltip_text = _data.description + "\n" + hp_line("生命值：", _data.hp, _brate);
		if (_data.shield > 0){
			_inst.tooltip_text += "\n" + hp_line("防具血量：", _data.shield, _brate);
		}
		// BOSS 区格子更宽（横 340 / 纵 280），裁剪框相应放大，免得 BOSS 被裁太多
		// 缩放不用改：instance 的 is_boss 会让它走 scale_boss 那一档
		_inst.is_boss    = true;
		_inst.clip_box_w = 300;
		_inst.clip_box_h = 250;
		array_push(mouse_preview_inst, _inst);
	}
	
	preview_dirty = false;
}

if (!global.console_open && keyboard_check_pressed(vk_escape)) || mouse_check_button_pressed(mb_right){
	instance_destroy();
}
