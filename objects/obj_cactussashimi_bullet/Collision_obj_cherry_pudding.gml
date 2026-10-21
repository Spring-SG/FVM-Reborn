if !bounced && row == other.grid_row{
	move_speed *= -1
	damage += other.atk
	image_angle += 180
	bounced = true
}