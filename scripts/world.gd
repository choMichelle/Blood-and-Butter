extends Node2D

@onready var player = %player

# Called when the node enters the scene tree for the first time.
func _ready():
	player.interact_pressed.connect(_on_interact_pressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("debug_load_game"):
		load_game()

# handle 'e' interactions
func _on_interact_pressed():
	var interactive_nodes = get_tree().get_nodes_in_group("interactive")
	for node in interactive_nodes:
		if node.scene_file_path.is_empty():
			print("interactive node '%s' is not an instanced scene, skipped" % node.name)
			continue
		
		# Check the node has a interaction function.
		if !node.has_method("start_interaction"):
			print("interactive node '%s' is missing a start_interaction() function, skipped" % node.name)
			continue
		
		node.call("start_interaction")

# load game data TODO - move to proper menu button
func load_game():
	if not FileAccess.file_exists("user://savegame.save"):
		return # Error! We don't have a save to load.

	# We need to revert the game state so we're not cloning objects
	# during loading. This will vary wildly depending on the needs of a
	# project, so take care with this step.
	# For our example, we will accomplish this by deleting saveable objects.
	var save_nodes = get_tree().get_nodes_in_group("persist")
	for i in save_nodes:
		i.queue_free()

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	var saved_game = FileAccess.open("user://savegame.save", FileAccess.READ)
	while saved_game.get_position() < saved_game.get_length():
		var json_string = saved_game.get_line()

		# Creates the helper class to interact with JSON
		var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		# Get the data from the JSON object
		var node_data = json.get_data()

		# Firstly, we need to create the object and add it to the tree and set its position.
		var new_object = load(node_data["filename"]).instantiate()
		get_node(node_data["parent"]).call_deferred("add_child", new_object)
		new_object.position = Vector2(node_data["pos_x"], node_data["pos_y"])

		# Now we set the remaining variables.
		for i in node_data.keys():
			if i == "filename" or i == "parent" or i == "pos_x" or i == "pos_y":
				continue
			new_object.set(i, node_data[i])
