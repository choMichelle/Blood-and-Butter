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
var JUMP_VELOCITY = -250.0

# enemy nodes and colliders
@onready var hurtbox = $enemy_hurtbox
@onready var enemy_sprite = $AnimatedSprite2D
@onready var detection_range = $enemy_detection_range
@onready var obs_detector = $AnimatedSprite2D/obstacle_detection

# player nodes
@onready var target = $"../../player"

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# initialize enemy stats, to be changed for unique enemies
func _init(_MAX_HEALTH = 5, _health = 5, _SPEED = 150.0):
	MAX_HEALTH = _MAX_HEALTH
	health = _health
	SPEED = _SPEED

func _ready():
	hurtbox.damage_taken.connect(_on_damage_taken)
	obs_detector.obstacle_detected.connect(_on_obstacle_detected)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	# change to DEAD state
	if health == 0:
		curr_state = states.DEAD
	print(health)

func _physics_process(delta):
	# add gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# enemy action state control
	match curr_state:
		states.NEUTRAL:
			velocity.x = 0
			if hurtbox.is_hit:
				detection_range.is_chasing = true
				curr_state = states.CHASE
		states.CHASE:
			obs_detector.ray.enabled = true
			follow_player()
			
			# stop chasing
			if detection_range.is_chasing == false:
				obs_detector.ray.enabled = false
				curr_state = states.NEUTRAL
		states.ATTACK:
			pass #TODO - code for attack state
		states.DEAD:
			pass #TODO - add code for when enemy is dead and edible
	
	# flip sprite
	if velocity.x > 0:
		enemy_sprite.scale.x = -1
	if velocity.x < 0:
		enemy_sprite.scale.x = 1
	
	move_and_slide()

# handle hurtbox being hit
func _on_damage_taken():
	if health > 0:
		health -= 1

# after detecting obstacle, jump over it
func _on_obstacle_detected():
	velocity.y = JUMP_VELOCITY

func follow_player():
	# find player
	var target_pos = target.position
	var target_dir = position.x - target_pos.x
	var direction = 0
	if target_dir > 0:
		direction = -1
	elif target_dir < 0:
		direction = 1
		
	# move to player
	if position.distance_to(target_pos) > 35:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
