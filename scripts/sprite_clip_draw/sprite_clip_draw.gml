/// @function sprite_clip_draw(_key, _spr, _subimg, _cx, _cy_bottom, _box_w, _box_h, _scale, _alpha)
/// @desc 把精灵按固定缩放画进一张 _box_w × _box_h 的裁剪面，再整体贴出来。
///       **不按精灵画布大小自适应**：画布大小不等于画面大小（各贴图透明留白占比 0.12~0.9 不等），
///       自适应会让留白多的贴图被额外缩小、显得比其他老鼠小一圈。缩放由调用方按"普通 / BOSS"
///       给一个统一值；绘制前还会用 sprite_trim_get() 按不透明包围盒裁掉透明留白，
///       超出裁剪框的部分交给 surface 裁掉。
///       锚点规则：按可见内容水平居中、底边贴住裁剪框底部（角色“站在”框底）。
/// @param {String}          _key        裁剪面标识；同尺寸共用一张面（如 "map" / "info"）
/// @param {Asset.GMSprite}  _spr        精灵资源
/// @param {Real}            _subimg     帧
/// @param {Real}            _cx         裁剪框水平中心
/// @param {Real}            _cy_bottom  裁剪框底边 y
/// @param {Real}            _box_w      裁剪框宽 = surface 宽（可配置）
/// @param {Real}            _box_h      裁剪框高 = surface 高（可配置）
/// @param {Real}            _scale      固定绘制缩放（不随精灵大小变化）
/// @param {Real}            _alpha      贴出时的透明度
function sprite_clip_draw(_key, _spr, _subimg, _cx, _cy_bottom, _box_w, _box_h, _scale = 1, _alpha = 1)
{
	if (_box_w <= 0 || _box_h <= 0 || _scale <= 0) return;
	
	var _sw = sprite_get_width(_spr);
	var _sh = sprite_get_height(_spr);
	if (_sw <= 0 || _sh <= 0) return;
	
	// 裁剪面登记表：按 key 复用一张面；尺寸变了就重建
	if (!variable_global_exists("sprite_clip_surfs")) global.sprite_clip_surfs = {};
	if (!struct_exists(global.sprite_clip_surfs, _key)){
		global.sprite_clip_surfs[$ _key] = { surf: -1, w: 0, h: 0 };
	}
	var _rec = global.sprite_clip_surfs[$ _key];
	var _bw  = ceil(_box_w);
	var _bh  = ceil(_box_h);
	if (!surface_exists(_rec.surf) || _rec.w != _bw || _rec.h != _bh){
		if (surface_exists(_rec.surf)) surface_free(_rec.surf);
		_rec.surf = surface_create(_bw, _bh);
		_rec.w    = _bw;
		_rec.h    = _bh;
	}
	// 显存/面数用尽时 surface_create 会失败（返回 -1）：这时宁可这帧不画，也不要去 set_target
	if (!surface_exists(_rec.surf)) return;
	
	// 固定缩放：同一类的贴图用同一个值，画布留白多的不会再被额外缩小
	var _s = _scale;
	
	// 按内容包围盒裁剪：只贴"看得见的那块"，否则留白大的贴图（如 hot_vajra 底部空 467px）
	// 会整个飘出裁剪框。查不到包围盒时退回整张画布。
	var _tb     = sprite_trim_get(_spr);
	var _px     = 0;
	var _py     = 0;
	var _pw     = _sw;
	var _ph     = _sh;
	if (!is_undefined(_tb)){
		_px = _tb[0];
		_py = _tb[1];
		_pw = _tb[2];
		_ph = _tb[3];
	}
	
	// 表面内坐标：按"可见内容"水平居中 + 底边贴框底
	var _dx = (_box_w - _pw * _s) * 0.5;
	var _dy = _box_h - _ph * _s;
	
	// surface_set_target() 是压栈、surface_reset_target() 是弹栈，必须成对。
	// 这里画完一律用 reset 弹回调用前的目标（情报岛是把整页画进 info_surface 的，
	// 弹栈后自然回到 info_surface，不需要也不允许用 set_target 手动"切回去"——
	// 那样等于又压一层，几帧后就会 surface stack is full）。
	surface_set_target(_rec.surf);
	draw_clear_alpha(c_black, 0);
	draw_sprite_part_ext(_spr, _subimg, _px, _py, _pw, _ph, _dx, _dy, _s, _s, c_white, 1);
	surface_reset_target();
	
	draw_surface_ext(_rec.surf, _cx - _box_w * 0.5, _cy_bottom - _box_h, 1, 1, 0, c_white, _alpha);
}
