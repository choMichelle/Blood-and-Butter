extends "enemy_common.gd"

func _init(_MAX_HEALTH = 10, _health = 10, _SPEED = 180.0):
	super(10,10,180.0)

func _process(delta):
	super(delta)
	print(health)

