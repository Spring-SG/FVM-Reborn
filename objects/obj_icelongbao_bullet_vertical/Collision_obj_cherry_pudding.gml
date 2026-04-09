if !bounced && col == other.grid_col{
	move_speed *= -1
	damage += other.atk
	image_angle += 180
	bounced = true
}