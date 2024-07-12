# contains singer(enemy)-specific stats and behaviours
extends "enemy_common.gd"

func _init(_max_health = 10, _health = 10, _SPEED = 180.0):
	super(10,10,180.0)

func _ready():
	super()
	Events.interact_pressed.connect(start_interaction)

func _process(delta):
	super(delta)

# start interaction TODO - limit interaction if dead
func start_interaction():
	if can_interact_with:
		interactable.start_dialogue()
