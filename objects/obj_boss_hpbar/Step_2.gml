if global.network.mode =="client"{
	if instance_exists(target_boss){
	hp = target_boss.hp
	if hp < 0 hp = 0
	maxhp = target_boss.maxhp;
	hp_rate = (hp*100) / maxhp ;
	hp_rate = hp_rate*0.01
	}
	else{
			hp = 0
			maxhp = 0
			hp_rate = 0
	}
}