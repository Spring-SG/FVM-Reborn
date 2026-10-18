panel_anim_step(id)
if (!instance_exists(id)) { exit }
// 绘制事件
draw_set_alpha(0.5 * ui_anim_alpha(id));
// 绘制半透明遮罩
draw_rectangle_color(0, 0, room_width, room_height, c_black, c_black, c_black, c_black, false);
draw_set_alpha(1);
panel_anim_begin(id)
draw_self()

// 绘制玩家金币数量
draw_set_font(font_number); 
draw_set_color(c_yellow);
draw_set_halign(fa_right);
draw_set_valign(fa_bottom);
draw_text(x - 485, y + 447, string(global.save_data.player.gold));
//绘制页码
draw_set_color(c_white);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(x + 387, y + 435, string(current_page)+"/"+string(current_max_page));
//绘制背景
draw_sprite_ext(spr_shop_bg_2,0,x,y+58,1.8,1.8,0,c_white,1)

// ── 页签/翻页切换：Crossfade + Stagger ──
// 旧内容：切换帧把上一帧录制的 pg_surf 拷进 pg_old_surf，之后原地淡出（不位移）。
// 新内容：16 格按 Z 字顺序错峰，单格 scale in + 淡入，整页不平移。
// 商品格内部会中途复位 draw_set_alpha，外层 alpha 无法逐格控制，因此整段先录 surface 再贴。
if (pg_t >= 0) {
pg_t++;
if (pg_t > pg_frames) pg_t = -1;
}
var _pg_prog = (pg_t >= 0) ? (pg_t / pg_frames) : 1;

// 切换那一帧：pg_surf 里还是上一帧的内容，先拷一份当旧内容
if (pg_switch) {
if (surface_exists(pg_surf) && surface_exists(pg_old_surf)) {
surface_copy(pg_old_surf, 0, 0, pg_surf);
}
pg_switch = false;
}

var _pg_anim = (pg_t >= 0 && pnl_o >= 0.999);

// 购买按钮是切页签时销毁重建的独立实例，不录制进 surface，跟随新内容淡入
if (_pg_anim) {
// 按钮入场：退回基准位后做 scale in + 上浮 + 淡入
var _nb  = 1 - power(1 - clamp(_pg_prog / 0.55, 0, 1), 3);
var _c1b = 1.70158;
var _nbb = 1 + (_c1b + 1) * power(_nb - 1, 3) + _c1b * power(_nb - 1, 2);
var _nsc = lerp(0.90, 1, _nbb);
var _ndir = pg_dir;
with (obj_shop_buy_btn) {
if (!variable_instance_exists(id, "bgs_x")) { bgs_x = x; bgs_y = y; bgs_s = image_xscale }
x = bgs_x + _ndir * 10 * (1 - _nb);
y = bgs_y + 14 * (1 - _nb);
image_xscale = bgs_s * _nsc;
image_yscale = bgs_s * _nsc;
image_alpha  = _nb;
pg_pop       = _nsc;
}
}

// 面板静止时每帧录制内容：切换帧才有上一帧可拷作旧内容
var _pg_live = false;
if (pnl_o >= 0.999) {
if (!surface_exists(pg_surf)) pg_surf = surface_create(room_width, room_height);
if (!surface_exists(pg_old_surf)) pg_old_surf = surface_create(room_width, room_height);
if (surface_exists(pg_surf)) {
surface_set_target(pg_surf);
draw_clear_alpha(c_black, 0);
_pg_live = true;
}
}

//绘制商品网格（随内容一起进出场，放在录制区内）
for(var i = 0 ; i< 4; i++){
	for(var j = 0; j < 4; j++){
		draw_sprite_ext(spr_shop_goods_bg,0,x-618+411*i,y-190+165*j,1.8,1.8,0,c_white,1)
	}
}

//按类型绘制图标

for(var i = 0 ; i< 4; i++){
	for(var j = 0; j < 4; j++){
		//绘制卡片类型商品
		if shop_button_select == 1{
			if ds_list_find_value(goods_list,i*4+j+(current_page-1)*16) != undefined{
				//根据商品id获取卡片信息
				var card_data = deck_get_card_data(global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*16)].unlock_item_id,0)
				draw_sprite_ext(spr_slot, 0, x-618+411*j-122,y-190+165*i, 0.33, 0.33, 0, c_white, 1);
				draw_sprite_ext(card_data[? "sprite"],0,x-618+411*j-122,y-190+165*i+25,1,1,0,c_white,1)
				draw_set_halign(fa_left);
				draw_set_valign(fa_middle);
				draw_set_color(c_black);
				draw_set_font(font_number);
				draw_text_ext_transformed(x-618+411*j-122-12, y-190+165*i+44, string(card_data[? "cost"]),25,1800,1,1,0);
				draw_sprite_ext(spr_flame, 0, x-618+411*j-122-24, y-190+165*i+43, 0.3, 0.3, 0, c_white, 1);
				draw_set_halign(fa_left);
				draw_set_valign(fa_top);
				// 检查卡片是否已解锁
		            var is_unlocked = false;
		            for(var k = 0; k < array_length(global.save_data.unlocked_cards); k++) {
		                if (global.save_data.unlocked_cards[k].id == global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*16)].unlock_item_id) {
		                    is_unlocked = true;
		                    break;
		                }
		            }
				if is_unlocked{
					
					draw_set_color(c_black)
					draw_set_alpha(0.5)
					draw_rectangle(x-618+411*j-205,y-190+165*i-82,x-618+411*j+205,y-190+165*i+82,false)
					draw_set_alpha(1)
					draw_sprite_ext(spr_sold_out, 0, x-618+411*j,y-190+165*i, 1.8, 1.8, 0, c_white, 1);
				}
			}
		}
		//绘制装备类型商品
		else if shop_button_select == 2{
			if ds_list_find_value(goods_list,i*4+j+(current_page-1)*16) != undefined{
				//根据id获取装备信息
				var goods_data = global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*16)]
				if goods_data.type == "weapon"{
					var weapon_data = get_weapon_info(goods_data.unlock_item_id)
					draw_sprite_ext(weapon_data.icon,0,x-618+411*j-122,y-210+165*i+25,1.5,1.5,0,c_white,1)
					//检查是否解锁
					var is_unlocked = is_weapon_unlocked(goods_data.unlock_item_id)
					if is_unlocked{
					
						draw_set_color(c_black)
						draw_set_alpha(0.5)
						draw_rectangle(x-618+411*j-205,y-190+165*i-82,x-618+411*j+205,y-190+165*i+82,false)
						draw_set_alpha(1)
						draw_sprite_ext(spr_sold_out, 0, x-618+411*j,y-190+165*i, 1.8, 1.8, 0, c_white, 1);
					}
				}
				else if goods_data.type == "gem"{
					var weapon_data = get_gem_info(goods_data.unlock_item_id)
					draw_sprite_ext(weapon_data.icon,0,x-618+411*j-122,y-210+165*i+25,0.9,0.9,0,c_white,1)
					//检查是否解锁
					var is_unlocked = is_gem_unlocked(goods_data.unlock_item_id)
					if is_unlocked{
					
						draw_set_color(c_black)
						draw_set_alpha(0.5)
						draw_rectangle(x-618+411*j-205,y-190+165*i-82,x-618+411*j+205,y-190+165*i+82,false)
						draw_set_alpha(1)
						draw_sprite_ext(spr_sold_out, 0, x-618+411*j,y-190+165*i, 1.8, 1.8, 0, c_white, 1);
					}
				}
			}
		}
		//绘制道具类型商品
		else if shop_button_select == 3{
			if ds_list_find_value(goods_list,i*4+j+(current_page-1)*16) != undefined{
				//根据商品id获取卡片信息
				var goods_info = global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*16)]
				var goods_spr = goods_info.spr
				
				draw_sprite_ext(goods_spr,0,x-618+411*j-122,y-215+165*i+25,1.8,1.8,0,c_white,1)
				
				//判断卡槽物品是否已售完
				if ((goods_info.unlock_item_id == "card_slot" && global.save_data.unlocked_items.max_slot >= 18)
					||(goods_info.unlock_item_id == "card_slot_19" && global.save_data.unlocked_items.max_slot > 18)
					||(goods_info.unlock_item_id == "card_slot_20" && global.save_data.unlocked_items.max_slot > 19)
					||(goods_info.unlock_item_id == "card_slot_21" && global.save_data.unlocked_items.max_slot > 20)
					)
				{
					draw_set_color(c_black)
					draw_set_alpha(0.5)
					draw_rectangle(x-618+411*j-205,y-190+165*i-82,x-618+411*j+205,y-190+165*i+82,false)
					draw_set_alpha(1)
					draw_sprite_ext(spr_sold_out, 0, x-618+411*j,y-190+165*i, 1.8, 1.8, 0, c_white, 1);
				}
				
			}
		}
		//绘制时装类型商品
		if shop_button_select == 4{
			if ds_list_find_value(goods_list,i*4+j+(current_page-1)*16) != undefined{
				//根据商品id获取卡片信息
				var card_data = global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*16)]
				var attire_data = get_attire_info(card_data.unlock_item_id)
				draw_sprite_ext(spr_slot, 0, x-618+411*j-122,y-190+165*i, 0.33, 0.33, 0, c_white, 1);
				draw_sprite_ext(attire_data.icon,0,x-618+411*j-122,y-190+165*i+25,1,1,0,c_white,1)
				draw_set_halign(fa_left);
				draw_set_valign(fa_middle);
				draw_set_color(c_black);
				draw_set_font(font_number);
				//draw_text_ext_transformed(x-618+411*j-122-12, y-190+165*i+44, "0",25,1800,1,1,0);
				//draw_sprite_ext(spr_flame, 0, x-618+411*j-122-24, y-190+165*i+43, 0.3, 0.3, 0, c_white, 1);
				draw_set_halign(fa_left);
				draw_set_valign(fa_top);
				// 检查时装是否已解锁
		            var is_unlocked = false;
		            if is_attire_unlocked(card_data.unlock_item_id){
						is_unlocked = true
					}
				if is_unlocked{
					
					draw_set_color(c_black)
					draw_set_alpha(0.5)
					draw_rectangle(x-618+411*j-205,y-190+165*i-82,x-618+411*j+205,y-190+165*i+82,false)
					draw_set_alpha(1)
					draw_sprite_ext(spr_sold_out, 0, x-618+411*j,y-190+165*i, 1.8, 1.8, 0, c_white, 1);
				}
			}
		}
		if shop_button_select == 5{
			if ds_list_find_value(goods_list,i*4+j+(current_page-1)*16) != undefined{
				//根据商品id获取卡片信息
				var card_data = global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*16)]
				var attire_data = get_attire_info(card_data.unlock_item_id)
				draw_sprite_ext(attire_data.icon,0,x-618+411*j-122,y-210+165*i+25,1,1,0,c_white,1)
				draw_set_halign(fa_left);
				draw_set_valign(fa_top);
				// 检查时装是否已解锁
		            var is_unlocked = false;
		            if is_attire_unlocked(card_data.unlock_item_id){
						is_unlocked = true
					}
				if is_unlocked{
					
					draw_set_color(c_black)
					draw_set_alpha(0.5)
					draw_rectangle(x-618+411*j-205,y-190+165*i-82,x-618+411*j+205,y-190+165*i+82,false)
					draw_set_alpha(1)
					draw_sprite_ext(spr_sold_out, 0, x-618+411*j,y-190+165*i, 1.8, 1.8, 0, c_white, 1);
				}
			}
		}
	}
}

if (_pg_live) {
surface_reset_target()
if (_pg_anim) {
// 旧内容退场：整体缩到 97.5%、下沉 5px、朝切换反方向偏 12px，在前 35% 时间内淡出
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
// 新内容入场：16 格 Z 字错峰，单格 scale in（0.90 → 1，带回弹）+ 淡入 + 自下方 14px 升起
var _cell_w = 411;
var _cell_h = 165;
var _gx     = x - 618 - 206;
var _gy     = y - 190 - 83;
var _c1     = 1.70158;
for (var r = 0; r < 4; r++) {
for (var c = 0; c < 4; c++) {
var _n   = r * 4 + c;
var _kp  = clamp((_pg_prog - _n * 0.028) / 0.58, 0, 1);
var _ke  = 1 - (1 - _kp) * (1 - _kp) * (1 - _kp);                      // ease-out cubic：透明度/位移
var _kb  = 1 + (_c1 + 1) * power(_kp - 1, 3) + _c1 * power(_kp - 1, 2); // ease-out back：缩放
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
draw_set_alpha(1)   // 别把透明度漏给收尾

panel_anim_end_slide(id, 260)
