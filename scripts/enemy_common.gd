# contains common enemy stats and behaviours
# to be inherited by enemy-specific scripts
extends CharacterBody2D

# enemy states
enum states {NEUTRAL, CHASE, ATTACK, DEAD}
var curr_state = states.NEUTRAL

# enemy stats
var MAX_HEALTH = 5
var health = 5
var SPEED = 150.0

# enemy nodes and colliders
@onready var hurtbox = $enemy_hurtbox
@onready var enemy_sprite = $AnimatedSprite2D
@onready var detection_range = $enemy_detection_range

# player nodes
@onready var target = $"../player"

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# initialize enemy stats, to be changed for unique enemies
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
	if hurtbox.is_hit and health > 0:
		health -= 1
		hurtbox.is_hit = false
	
	# change to DEAD state
	if health == 0:
		curr_state = states.DEAD
		
	print(curr_state)

func _physics_process(delta):
	# add gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# enemy action state control
	match curr_state:
		states.NEUTRAL:
			if hurtbox.is_hit:
				detection_range.is_chasing = true
				curr_state = states.CHASE
		states.CHASE:
			# find player
			var target_pos = target.position
			var target_dir = position.x - target_pos.x
			var direction = 0
			if target_dir > 0:
				direction = -1
			elif target_dir < 0:
				direction = 1
				
			# move to player
			velocity.x = direction * SPEED
			if position.distance_to(target_pos) > 20:
				move_and_slide()
			
			if detection_range.is_chasing == false:
				curr_state = states.NEUTRAL
		states.ATTACK:
			pass
		states.DEAD:
			pass #TODO - add code for when enemy is dead
	
	# flip sprite
	if velocity.x > 0:
		enemy_sprite.scale.x = -1
	if velocity.x < 0:
		enemy_sprite.scale.x = 1
