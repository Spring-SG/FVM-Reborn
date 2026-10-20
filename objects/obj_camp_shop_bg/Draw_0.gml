// 绘制事件
panel_anim_step(id)
if (!instance_exists(id)) { exit }
draw_set_alpha(0.5 * ui_anim_alpha(id));
// 绘制半透明遮罩
draw_rectangle_color(0, 0, room_width, room_height, c_black, c_black, c_black, c_black, false);
draw_set_alpha(1);
panel_anim_begin(id)
draw_self()

// 绘制玩家金币数量
draw_sprite_ext(spr_camp_shop_coin_display,0,x+240,y-290,1.8,1.8,0,c_white,1)
draw_sprite_ext(spr_camp_shop_coin_display,0,x+570,y-290,1.8,1.8,0,c_white,1)
draw_sprite_ext(spr_craft_material,13,x+130,y-290,0.8,0.8,0,c_white,1)
draw_sprite_ext(spr_craft_material,14,x+460,y-290,0.8,0.8,0,c_white,1)
draw_set_font(font_yuan); 
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_middle);
draw_text_transformed(x + 170, y - 290, string(get_material_amount("less_camp_coin")),1.2,1.2,0);
draw_text_transformed(x + 500, y - 290, string(get_material_amount("camp_coin")),1.2,1.2,0);
//绘制页码
draw_set_color(c_black);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_sprite_ext(spr_camp_shop_page_bg,0,x,y+428,1.8,1.8,0,c_white,1)
draw_text(x, y + 428, string(current_page)+"/"+string(current_max_page));

// ── 翻页动画：Crossfade + Stagger，参数与 obj_shop_bg/Draw_0.gml 一致 ──
// 旧内容原地缩小下沉淡出，新内容 12 格（3 行 × 4 列）按 Z 字错峰 scale in。
if (pg_t >= 0) {
pg_t++;
if (pg_t > pg_frames) pg_t = -1;
}
var _pg_prog = (pg_t >= 0) ? (pg_t / pg_frames) : 1;

if (pg_switch) {
if (surface_exists(pg_surf) && surface_exists(pg_old_surf)) {
surface_copy(pg_old_surf, 0, 0, pg_surf);
}
pg_switch = false;
}

var _pg_stable = true
if (variable_instance_exists(id, "pnl_o")) { _pg_stable = (pnl_o >= 0.999) }
var _pg_anim = (pg_t >= 0 && _pg_stable);

// 购买按钮在翻页时重建，属独立实例，单独做同款入场
if (_pg_anim) {
var _nb  = 1 - power(1 - clamp(_pg_prog / 0.55, 0, 1), 3);
var _c1b = 1.70158;
var _nbb = 1 + (_c1b + 1) * power(_nb - 1, 3) + _c1b * power(_nb - 1, 2);
var _nsc = lerp(0.90, 1, _nbb);
var _ndir = pg_dir;
with (obj_camp_shop_buy_btn) {
if (!variable_instance_exists(id, "bgs_x")) { bgs_x = x; bgs_y = y; bgs_s = image_xscale }
x = bgs_x + _ndir * 10 * (1 - _nb);
y = bgs_y + 14 * (1 - _nb);
image_xscale = bgs_s * _nsc;
image_yscale = bgs_s * _nsc;
image_alpha  = _nb;
}
}

var _pg_live = false;
if (_pg_stable) {
if (!surface_exists(pg_surf)) pg_surf = surface_create(room_width, room_height);
if (!surface_exists(pg_old_surf)) pg_old_surf = surface_create(room_width, room_height);
if (surface_exists(pg_surf)) {
surface_set_target(pg_surf);
draw_clear_alpha(c_black, 0);
_pg_live = true;
}
}

//绘制商品网格
for(var i = 0 ; i< 4; i++){
	for(var j = 0; j < 3; j++){
		draw_sprite_ext(spr_camp_shop_goods_bg,0,x-590+380*i,y-130+190*j,1.8,1.8,0,c_white,1)
	}
}

//按类型绘制图标

for(var i = 0 ; i< 3; i++){
	for(var j = 0; j < 4; j++){
		//绘制卡片类型商品
		if shop_button_select == 1{
			if ds_list_find_value(goods_list,i*4+j+(current_page-1)*12) != undefined{
				//根据商品id获取卡片信息
				var card_data = deck_get_card_data(global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*12)].unlock_item_id,global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*12)].target_shape)
				draw_sprite_ext(spr_slot, 0, x-590+380*j-105,y-130+190*i, 0.33, 0.33, 0, c_white, 1);
				draw_sprite_ext(card_data[? "sprite"],0,x-590+380*j-105,y-130+190*i+25,1,1,0,c_white,1)
				draw_set_halign(fa_left);
				draw_set_valign(fa_middle);
				draw_set_color(c_black);
				draw_set_font(font_number);
				draw_text_ext_transformed(x-590+380*j-105-12, y-130+190*i+44, string(card_data[? "cost"]),25,1800,1,1,0);
				draw_sprite_ext(spr_flame, 0, x-590+380*j-105-24, y-130+190*i+43, 0.3, 0.3, 0, c_white, 1);
				draw_set_halign(fa_left);
				draw_set_valign(fa_top);
				// 检查卡片是否已解锁
		            var is_unlocked = false;
		            for(var k = 0; k < array_length(global.save_data.unlocked_cards); k++) {
		                if (global.save_data.unlocked_cards[k].id == global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*12)].unlock_item_id) {
		                    if get_card_info_simple(global.save_data.unlocked_cards[k].id).max_shape >= global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*12)].target_shape{
			                    is_unlocked = true;
			                    break;
							}
		                }
		            }
				if is_unlocked{
					
					draw_set_color(c_black)
					draw_set_alpha(0.5)
					draw_rectangle(x-590+380*j-188,y-130+190*i-86,x-590+380*j+188,y-130+190*i+86,false)
					draw_set_alpha(1)
					//draw_sprite_ext(spr_camp_shop_sold_out, 0, x-590+380*j,y-130+190*i, 1.8, 1.8, 0, c_white, 1);
					//instance_create_depth(x-590+380*j,y-130+190*i,depth-2,obj_sold_out_icon)
				}
			}
		}
	}
}
if (_pg_live) {
surface_reset_target()
if (_pg_anim) {
// 旧内容退场：原地缩小 + 下沉 + 淡出（前 35% 时间内完成）
var _oe = 1 - power(1 - clamp(_pg_prog / 0.35, 0, 1), 3);
if (surface_exists(pg_old_surf)) {
var _osc = lerp(1, 0.975, _oe);
var _ow  = room_width * _osc;
var _oh  = room_height * _osc;
draw_surface_ext(pg_old_surf,
                 (room_width - _ow) * 0.5 - pg_dir * 12 * _oe,
                 (room_height - _oh) * 0.5 + 5 * _oe,
                 _osc, _osc, 0, c_white, 1 - _oe);
}
// 新内容入场：12 格（3 行 × 4 列）Z 字错峰 scale in + 淡入
var _cell_w = 380;
var _cell_h = 190;
var _gx     = x - 780;
var _gy     = y - 225;
var _c1     = 1.70158;
for (var r = 0; r < 3; r++) {
for (var c = 0; c < 4; c++) {
var _n   = r * 4 + c;
var _kp  = clamp((_pg_prog - _n * 0.028) / 0.58, 0, 1);
var _ke  = 1 - (1 - _kp) * (1 - _kp) * (1 - _kp);
var _kb  = 1 + (_c1 + 1) * power(_kp - 1, 3) + _c1 * power(_kp - 1, 2);
var _sc  = lerp(0.90, 1, _kb);
var _kdx = pg_dir * 10 * (1 - _ke);
var _kdy = 14 * (1 - _ke);
var _cx  = _gx + c * _cell_w + _cell_w * 0.5 + _kdx;
var _cy  = _gy + r * _cell_h + _cell_h * 0.5 + _kdy;
draw_surface_part_ext(pg_surf, _gx + c * _cell_w, _gy + r * _cell_h, _cell_w, _cell_h,
                      _cx - _cell_w * _sc * 0.5, _cy - _cell_h * _sc * 0.5,
                      _sc, _sc, c_white, _ke);
}
}
}
else {
draw_surface_ext(pg_surf, 0, 0, 1, 1, 0, c_white, 1);
}
}
draw_set_alpha(1)

panel_anim_end_slide(id, 260)
