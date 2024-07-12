extends Area2D

@export var dialogue_res: DialogueResource
@export var dialogue_start: String = "start"

var in_range: bool = false

signal in_interact_range(in_range)

func _on_body_entered(body):
	in_range = true
	in_interact_range.emit(in_range)

func _on_body_exited(body):
	in_range = false
	in_interact_range.emit(in_range)

func start_dialogue():
	Events.dialogue_started.emit()
	DialogueManager.show_example_dialogue_balloon(dialogue_res, dialogue_start)
