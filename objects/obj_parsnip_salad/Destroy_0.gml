// Inherit the parent event
event_inherited();

for(var i = 0 ; i < array_length(maxhp_increase_card_list) ; i ++){
	if maxhp_increase_card_list[i] != noone && instance_exists(maxhp_increase_card_list[i]){
		with maxhp_increase_card_list[i]{
			max_hp -= other.atk
			if hp > max_hp{
				hp = max_hp
			}
		}
	}
}

// 解除本沙拉提供的沙漠风保护（范围固定 5x5，可能大于加血/加血上限的范围）
// 注意：防风草自带的防风不来自任何沙拉，铲掉这株防风草不能连带清掉别的防风草
for(var i = 0 ; i < array_length(desert_wind_card_list) ; i ++){
	if desert_wind_card_list[i] != noone && instance_exists(desert_wind_card_list[i]){
		with desert_wind_card_list[i]{
			if plant_id != "parsnip_salad"{
				desert_wind_protect = false
			}
		}
	}
}