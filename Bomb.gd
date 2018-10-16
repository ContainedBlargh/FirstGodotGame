extends Area2D

signal exploded;

var countdown_started = false
var exploding = false

func _process(delta):
	if not countdown_started:
		$Countdown.start()
		countdown_started = true
	$AnimatedSprite.play()
	var countdown_time_left = $Countdown.time_left
	if not exploding and countdown_time_left <= 0.0:
		$Exploding.start()
		$AnimatedSprite.animation = "exploding"
		var rot = float(randi() % 360)
		$AnimatedSprite.scale *= 4.0
		$AnimatedSprite.rotation = (deg2rad(rot))
		$CollisionShape2D.scale *= 6.0
		$AnimatedSprite.play()
		exploding = true
		return
	var exploding_time_left = $Exploding.time_left
	if exploding and exploding_time_left <= 0.0:
		hide()
		$CollisionShape2D.disabled = true
		emit_signal("exploded")
		queue_free()
	pass
	
func _ready():
	set_process(true)
	pass

