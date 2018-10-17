extends Node

export (PackedScene) var Mob

signal game_over
var score

func game_over():
	emit_signal("game_over")
	$MobTimer.stop()
	$HUD.show_game_over()

func new_game():
	score = 0
	$HUD.update_score(score)
	$HUD.show_message("Get Ready!")
	$Player.start($StartPosition.position)
	$StartTimer.start()

func _ready():
	randomize()
	OS.set_window_maximized(true)
	pass

func score():
	score += 1
	$HUD.update_score(score)

func _on_StartTimer_timeout():
	$HUD.update_score(score)
	$MobTimer.start()
	pass # replace with function body

func _on_MobTimer_timeout():
	# Choose a random location on Path2D.
	$MobPath/MobSpawnLocation.set_offset(randi())
	# Create a Mob instance and add it to the scene.
	var mob = Mob.instance()
	mob.connect("dead", self, "score")
	self.connect("game_over", mob, "_on_Exploding_timeout")
	add_child(mob)
	# Set the mob's direction perpendicular to the path direction.
	var direction = $MobPath/MobSpawnLocation.rotation + PI / 2
	# Set the mob's position to a random location.
	mob.position = $MobPath/MobSpawnLocation.position
	# Add some randomness to the direction.
	direction += rand_range(-PI / 4, PI / 4)
	mob.rotation = direction
	# Choose the velocity.
	mob.set_linear_velocity(Vector2(rand_range(mob.min_speed, mob.max_speed), 0).rotated(direction))
