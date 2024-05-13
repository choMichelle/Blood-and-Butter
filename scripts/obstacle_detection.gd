# obstacle detector/jump trigger for chasing enemies
extends Node2D

@onready var ray = $ray
signal obstacle_detected

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if ray.is_colliding():
		obstacle_detected.emit()
