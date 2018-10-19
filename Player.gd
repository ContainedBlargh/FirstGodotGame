extends Area2D

signal hit
signal sprint_ready

export (Vector2) var velocity = Vector2(0.0, 0.0)
export (int) var bomb_limit = 3

var sprint_charging = false

var power = 0.0 #Current forward movement of player

const size = 40
var screensize #Size of the screen

const rotation_delta_constant = 3.0
var rotation_delta = rotation_delta_constant
var orientation = 0.0

const max_power = 100
const power_delta = 0.1

var engines_maxed = false
var engines_running = false

var bomb_scene = preload("res://Bomb.tscn")
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
	if power < max_power:
		engines_maxed = false
		power += (max_power) * power_delta
		if power > max_power:
			power = max_power
	else:
		engines_maxed = true
	
func decelerate():
	engines_maxed = false
	if power > 0:
		power -= ((max_power) * power_delta)
	else:
		engines_running = false
	if power <= 0:
		power = 0.0
	pass

func neutralize():
	velocity = velocity * 0.0
	pass

func afterburner():
	if not sprint_charging:
		power = max_power * 2
		$SprintTimer.start()
		engines_running = true
		engines_maxed = true
	pass

func disable_afterburner():
	if engines_maxed:
		power = max_power
		$SprintTimer.stop()
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
	if Input.is_action_pressed("neutralize"):
		neutralize()
	if Input.is_action_just_pressed("afterburner"):
		afterburner()
	if Input.is_action_just_released("afterburner"):
		disable_afterburner()
	if Input.is_action_just_released("bomb"):
		drop_bomb()
		
	pass

func modify_rotation_delta():
	if not engines_running:
		rotation_delta = rotation_delta_constant * 1.34
	else:
		rotation_delta = rotation_delta_constant
	if engines_maxed:
		rotation_delta = rotation_delta_constant * 0.34

func update_position(delta):
	var rad = deg2rad(orientation)
	var heading = Vector2(cos(rad), sin(rad))
	var position_modifier = heading * power
	velocity = velocity.normalized() + (position_modifier * delta)
	position += velocity
	position.x = clamp(position.x, size, screensize.x - size)
	position.y = clamp(position.y, size, screensize.y - size)
	pass

func update_animation():
	$AnimatedSprite.rotation = deg2rad(orientation + 90.0)
	if engines_running:
		$AnimatedSprite.set_frame(1)
	else:
		$AnimatedSprite.set_frame(0)
	
	if engines_maxed:
		$AnimatedSprite.set_frame(2)
	
	if power > max_power:
		$AnimatedSprite.set_frame(3)
	
	if power < 0.6:
		engines_running = false
		$AnimatedSprite.set_frame(0)

func update_collision_shape():
	$CollisionShape2D.rotation = deg2rad(orientation + 90.0)
	pass

func _on_SprintTimer_timeout():
	sprint_charging = false
	power -= max_power
	emit_signal("sprint_ready")
	pass # replace with function body

func update_player_state(delta):
	pass

func _on_Player_body_entered(body):
	if body.is_in_group("Bombs"):
		return
	if body.is_in_group("Mobs"):
		var mob = body
		if mob.alive:
			hide()
			emit_signal("hit")
			$CollisionShape2D.disabled = true
	pass

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false

func _process(delta):
	handle_input()
	modify_rotation_delta()
	update_position(delta)
	update_animation()
	update_collision_shape()
	update_player_state(delta)
	screensize = get_viewport_rect().size

func _ready():
	screensize = get_viewport_rect().size
	$AnimatedSprite.rotation = deg2rad(0.0)
	set_process(true)
	pass


