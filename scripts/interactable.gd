extends Area2D

var in_range: bool = false

signal in_interact_range(in_range)

func _on_body_entered(body):
	in_range = true
	in_interact_range.emit(in_range)

func _on_body_exited(body):
	in_range = false
	in_interact_range.emit(in_range)
