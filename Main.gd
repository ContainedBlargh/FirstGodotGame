extends Node

export (PackedScene) var Mob

signal game_over
var score
var mob_speed_modifier = 1.0

var music = true
var game_in_progress = false

func game_over():
	game_in_progress = false
	if music:
		$Tune.stop()
		$Loop.play()
	emit_signal("game_over")
	$MobTimer.stop()
	$HUD.show_game_over()

func new_game():
	game_in_progress = true
	score = 0
	$HUD.update_score(score)
	$HUD.show_message("Get Ready!")
	$Player.start($StartPosition.position)
	if music:
		$Fanfare.play()
		$FanfareTimer.start()
		$Loop.stop()
	$StartTimer.start()

func _on_FanfareTimer_timeout():
	if music:
		$Fanfare.stop()
		$Tune.play()
	pass # replace with function body

func mute_music():
	if music:
		$Tune.stop()
		$Fanfare.stop()
		$Loop.stop()
		music = false
	else:
		if game_in_progress:
			$Tune.play()
		else:
			$Loop.play()
		music = true
	$HUD/Music.release_focus()
	pass

func _ready():
	randomize()
	OS.set_window_maximized(true)
	$HUD/Music.connect("pressed", self, "mute_music")
	pass

func score():
	score += 1
	if score % 10 == 0:
		mob_speed_modifier = (score / 10.0)
		$Player.bomb_limit += 1
		$Player/SprintTimer.wait_time = (score / 10.0)
		pass
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
	mob.set_linear_velocity(Vector2(rand_range(mob.min_speed * mob_speed_modifier, mob.max_speed * mob_speed_modifier), 0).rotated(direction))

