# add to enemy scenes (+collisionShape), used in controlling chase state
extends Area2D

@onready var chase_timer = $Timer
var is_chasing: bool = false

# when player enters detection range
func _on_body_entered(body):
	if body.name == "player" and is_chasing:
		chase_timer.stop()

# when player exits detection range
func _on_body_exited(body):
	if body.name == "player" and is_chasing:
		chase_timer.start(5)

func _on_timer_timeout():
	chase_timer.stop()
	is_chasing = false
