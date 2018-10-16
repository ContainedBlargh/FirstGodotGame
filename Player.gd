extends Area2D

signal hit

export (float) var velocity = 0.0 #Current forward movement of player

const size = 40
var screensize #Size of the screen

var rotation_delta = 3.0
var orientation = 0.0

const max_velocity = 4.0
var full_speed = false
var engines_running = false

var bomb_scene = preload("res://Bomb.tscn")
var bomb_limit = 3
var bombs = 0

func turn_left():
	if orientation > 0.0:
		orientation -= rotation_delta
	else:
		orientation = 360.0 - rotation_delta
	pass

func turn_right():
	orientation = fmod(orientation + rotation_delta, 360.0)
	pass

func accelerate():
	engines_running = true
	if velocity < max_velocity:
		full_speed = false
		velocity += (max_velocity) * 0.1
	else:
		full_speed = true
	
func decelerate():
	full_speed = false
	if velocity > 0:
		velocity -= max((max_velocity) * 0.1, 0.0)
	else:
		engines_running = false
	pass

func bomb_exploded():
	bombs -= 1

func drop_bomb():
	if bombs < bomb_limit:
		var bomb = bomb_scene.instance()
		bomb.position = position
		bomb.connect("exploded", self, "bomb_exploded")
		get_parent().add_child(bomb)
		bombs += 1
	pass

func handle_input():
	if Input.is_action_pressed("turn_left"):
		turn_left()
	if Input.is_action_pressed("turn_right"):
		turn_right()
	if Input.is_action_pressed("accelerate"):
		accelerate()
	if Input.is_action_pressed("decelerate"):
		decelerate()
	if Input.is_action_just_released("bomb"):
		drop_bomb()
		
	pass

func modify_rotation_delta():
	if not engines_running:
		rotation_delta = 5.0
	else:
		rotation_delta = 4.0
	if full_speed:
		rotation_delta = 2.0

func update_position():
	var rad = deg2rad(orientation)
	var heading = Vector2(cos(rad), sin(rad))
	var position_modifier = heading * velocity
	position += position_modifier
	position.x = clamp(position.x, size, screensize.x - size)
	position.y = clamp(position.y, size, screensize.y - size)
	pass

func update_animation():
	$AnimatedSprite.rotation = deg2rad(orientation + 90.0)
	if engines_running:
		$AnimatedSprite.set_frame(1)
	else:
		$AnimatedSprite.set_frame(0)
	
	if full_speed:
		$AnimatedSprite.set_frame(2)
	
	if velocity < 0.6:
		engines_running = false
		$AnimatedSprite.set_frame(0)

func _on_Player_body_entered(body):
	if body.is_in_group("Bombs"):
		return
	hide()
	emit_signal("hit")
	$CollisionShape2D.disabled = true
	pass # replace with function body

func _process(delta):
	handle_input()
	modify_rotation_delta()
	update_position()
	update_animation()
	screensize = get_viewport_rect().size

func _ready():
	screensize = get_viewport_rect().size
	$AnimatedSprite.rotation = deg2rad(0.0)
	set_process(true)
	pass
