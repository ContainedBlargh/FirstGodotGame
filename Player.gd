extends Area2D

export (float) var velocity #Current forward movement of player

const max_velocity = 100.0
const min_velocity = -100.0
const size = 40

var orientation = 0.0

var screensize #Size of the screen

func turn_left():
	print("Turning left!")
	orientation = (orientation + 1.0) % 360.0
	pass

func turn_right():
	print("Turning right!")
	if orientation > 0.0:
		orientation -= 1
	else:
		orientation = 359.0
	pass

func accelerate():
	print("Accelerating!")
	if velocity < max_velocity:
		print("Old velocity: {}".format(velocity))
		velocity += (velocity + 1) * 0.1
		print("New velocity: {}".format(velocity))
	pass
	
func decelerate():
	if velocity > min_velocity:
		velocity -= (velocity + 1) * 0.1
	pass

func get_orientation():
	return orientation

func handle_input():
	if Input.is_action_pressed("turn_left"):
		print("Got ui_left action!")
		turn_left()
	if Input.is_action_pressed("turn_right"):
		print("Got ui_right action!")
		turn_right()
	if Input.is_action_pressed("accelerate"):
		print("Got ui_up action!")
		accelerate()
	if Input.is_action_pressed("decelerate"):
		print("Got ui_down action!")
		decelerate()
	pass

func update_position():
	print("Updating position...")
	print("Old position: {}".format(position))
	var rad = deg2rad(orientation)
	var heading = Vector2(cos(rad), sin(rad))
	var position_modifier = heading * velocity
	position += position_modifier
	position.x = clamp(position.x, size, screensize.x - size)
	position.y = clamp(position.y, size, screensize.y - size)
	print("New position: {}".format(position))
	pass

func update_animation():
	$AnimatedSprite.play()
	pass

func _process():
	print("process called!")
	if Input.is_key_pressed(KEY_B):
		print("press B to jump")
		pass
	handle_input()
	update_position()
	update_animation()

func _ready():
	print("ready called")
	screensize = get_viewport_rect().size
	pass