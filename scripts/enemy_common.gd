extends CharacterBody2D

# enemy states
enum {NEUTRAL, CHASE, ATTACK, DEAD}

var MAX_HEALTH = 5
var health = 5
@onready var hurtbox = $enemy_hurtbox
@onready var enemy_sprite = $AnimatedSprite2D

var SPEED = 150.0

@onready var target = $"../player"

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _init(_MAX_HEALTH = 5, _health = 5, _SPEED = 150.0):
	MAX_HEALTH = _MAX_HEALTH
	health = _health
	SPEED = _SPEED

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	# process damage taken
	if hurtbox.is_hit == true and health > 0:
		health -= 1
		hurtbox.is_hit = false

func _physics_process(delta):
	# gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# chase player
	var target_pos = target.position
	var target_dir = position.x - target_pos.x
	var direction = 0
	if target_dir > 0:
		direction = -1
	elif target_dir < 0:
		direction = 1
	
	velocity.x = direction * SPEED
	if position.distance_to(target_pos) > 20:
		move_and_slide()
	
	# flip sprite
	if velocity.x > 0:
		enemy_sprite.scale.x = -1
	if velocity.x < 0:
		enemy_sprite.scale.x = 1
