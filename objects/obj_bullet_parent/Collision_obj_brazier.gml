/// 被火盆点燃：同一火盆只记一次，可累计多层燃烧
if (!bullet_collides_brazier) exit;
if (ds_list_find_index(brazier_list, other.id) != -1) exit;
if (burnt >= bullet_max_burn) exit;
if (!bullet_brazier_row_ok(other)) exit;

burnt += 1;
if (burnt >= bullet_burn_damage_level) damage = round(damage * other.atk);
ds_list_add(brazier_list, other.id);
global.audio.play(snd_bullet_burnt, 0, 0);
bullet_on_burnt();