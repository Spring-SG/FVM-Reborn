// Inherit the parent event
event_inherited();

if (global.network.mode != "client") {
	if !instance_exists(train_head){
		instance_destroy()
	}
	else{
		if train_head.hp <= 0{
			hp = 0
		}
		if hp < maxhp && train_head.hp > 0{
			train_head.hp -= (maxhp-hp)
			hp = maxhp
		}
	}
}

frozen_timer = 0
stun_timer = 0
scare_timer = 0
y_move = 0