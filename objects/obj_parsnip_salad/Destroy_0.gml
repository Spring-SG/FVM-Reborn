// Inherit the parent event
event_inherited();

for(var i = 0 ; i < array_length(maxhp_increase_card_list) ; i ++){
	if maxhp_increase_card_list[i] != noone && instance_exists(maxhp_increase_card_list[i]){
		with maxhp_increase_card_list[i]{
			max_hp -= other.atk
			if hp > max_hp{
				hp = max_hp
			}
			desert_wind_protect = false
		}
	}
}