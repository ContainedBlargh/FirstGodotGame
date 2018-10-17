extends RigidBody2D

signal dead

export (int) var min_speed
export (int) var max_speed

export (bool) var alive = true

func _process(delta):
	$AnimatedSprite.rotation = fmod($AnimatedSprite.rotation + delta, 360.0)

func _ready():
	set_process(true)

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
	pass # replace with function body

func _on_Mob_body_entered(body):
	if body.is_in_group("Bombs"):
		var bomb = body
		if bomb.exploding:
			emit_signal("dead")
			alive = false
			$Exploding.start()
			$CollisionShape2D.disabled = true
			$AnimatedSprite.set_frame(1)
			pass
	pass # replace with function body


func _on_Exploding_timeout():
	hide()
	queue_free()
	pass # replace with function body
