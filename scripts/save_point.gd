extends Node2D

@onready var interactable = $interactable
var can_interact_with: bool = false

func _ready():
	interactable.in_interact_range.connect(_on_in_interact_range)
	Events.interact_pressed.connect(start_interaction)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# check if player is within interaction range
func _on_in_interact_range(in_range):
	if in_range:
		can_interact_with = true
	else:
		can_interact_with = false

# action to be called when player interacts
func start_interaction():
	if can_interact_with:
		save_game()

# Go through everything in the persist category and ask them to return a
# dict of relevant variables.
func save_game():
	var saved_game = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("persist")
	for node in save_nodes:
		# Check the node is an instanced scene so it can be instanced again during load.
		if node.scene_file_path.is_empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue

		# Check the node has a save function.
		if !node.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue

		# Call the node's save function.
		var node_data = node.call("save")
		print("save success")

		# JSON provides a static method to serialized JSON string.
		var json_string = JSON.stringify(node_data)

		# Store the save dictionary as a new line in the save file.
		saved_game.store_line(json_string)
	saved_game.close()

