extends Node2D

@onready var ray_left = $ray_left
signal obstacle_detected

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if ray_left.is_colliding():
		obstacle_detected.emit()


func _on_obstacle_detected():
	pass # Replace with function body.
