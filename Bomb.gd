extends RigidBody2D

signal exploded;
export (bool) var exploding = false

func explode():
	$Exploding.start()
	$AnimatedSprite.animation = "exploding"
	var rot = float(randi() % 360)
	$AnimatedSprite.scale *= 4.0
	$AnimatedSprite.rotation = (deg2rad(rot))
	$CollisionShape2D.scale *= 8.0
	$AnimatedSprite.play()
	exploding = true
	return

func snuff_out():
	hide()
	$CollisionShape2D.disabled = true
	emit_signal("exploded")
	queue_free()
	
func _ready():
	$AnimatedSprite.play()
	$Countdown.start()
	$CollisionShape2D.disabled = false
	pass

