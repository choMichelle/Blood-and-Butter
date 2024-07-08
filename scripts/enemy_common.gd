# contains common enemy stats and behaviours
# to be inherited by enemy-specific scripts
extends CharacterBody2D

# enemy states
enum states {NEUTRAL, CHASE, ATTACK, DYING, EDIBLE}
var curr_state = states.NEUTRAL

# enemy stats
var MAX_HEALTH = 5
var health = 5
var SPEED = 150.0
var JUMP_VELOCITY = -250.0
var KNOCKBACK_POWER = 150.0 # applied to self

var is_hit: bool = false
var melee_range = 60
var is_attacking1: bool = false
var is_attacking2: bool = false

# enemy nodes and colliders
@onready var hurtbox = $enemy_hurtbox
@onready var enemy_sprite = $AnimatedSprite2D
@onready var detection_range = $enemy_detection_range
@onready var obs_detector = $AnimatedSprite2D/obstacle_detection

# attack nodes
@onready var melee1_hitbox = $AnimatedSprite2D/hitboxes/hitbox_collider1
@onready var melee2_hitbox = $AnimatedSprite2D/hitboxes/hitbox_collider2

# player targetting nodes and variables
@onready var target = %player
var target_pos
var target_dir

var direction = 0 # direction to player, used to chase

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# initialize enemy stats, to be changed for unique enemies
func _init(_MAX_HEALTH = 5, _health = 5, _SPEED = 150.0):
	MAX_HEALTH = _MAX_HEALTH
	health = _health
	SPEED = _SPEED

func _ready():
	enemy_sprite.animation_finished.connect(_on_animation_finished)
	hurtbox.damage_taken.connect(_on_damage_taken)
	hurtbox.bite_taken.connect(_on_bite_taken)
	obs_detector.obstacle_detected.connect(_on_obstacle_detected)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# change to DEAD state
	if curr_state != states.EDIBLE and health == 0:
		curr_state = states.DYING
		enemy_sprite.play("death")

func _physics_process(delta):
	# add gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	
	find_player_direction()
	
	# enemy action state control
	match curr_state:
		states.NEUTRAL:
			velocity.x = 0
		states.CHASE:
			obs_detector.ray.enabled = true
			if !is_hit:
				follow_player()
			
			# stop chasing
			if detection_range.is_chasing == false:
				obs_detector.ray.enabled = false
				curr_state = states.NEUTRAL
		states.ATTACK:
			pass #TODO - code for attack state
		states.DYING:
			velocity.x = 0
		states.EDIBLE:
			velocity.x = 0
	
	play_animations()
	
	# flip sprite
	if !is_hit:
		if velocity.x > 0:
			enemy_sprite.scale.x = -1
		if velocity.x < 0:
			enemy_sprite.scale.x = 1
	
	move_and_slide()

# handle hurtbox being hit
# hit by attacks
func _on_damage_taken(knockback_direction):
	# take damage if not dead
	if health > 0:
		health -= 1
		velocity.x += knockback_direction * KNOCKBACK_POWER
		is_hit = true
		
	# change state to aggro
	if curr_state == states.NEUTRAL:
		detection_range.is_chasing = true
		curr_state = states.CHASE

# hit by eat attack
func _on_bite_taken():
	if curr_state == states.EDIBLE:
		target.recover_health(2)
		queue_free()
	else:
		if health > 0:
			health -= 2
			is_hit = true

# after detecting obstacle, jump over it
func _on_obstacle_detected():
	velocity.y = JUMP_VELOCITY

func find_player_direction():
	target_pos = target.position
	target_dir = position.x - target_pos.x
	if target_dir > 0:
		direction = -1
	elif target_dir < 0:
		direction = 1

func follow_player():
	# move to player
	if position.distance_to(target_pos) > melee_range:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	if position.distance_to(target_pos) < melee_range:
		is_attacking1 = true

func play_animations():
	if curr_state == states.DYING:
		melee1_hitbox.disabled = false
		melee2_hitbox.disabled = false
		enemy_sprite.play("death")
	if curr_state == states.EDIBLE:
		enemy_sprite.play("edible")
	
	if curr_state != states.DYING and curr_state != states.EDIBLE:
		if is_attacking1 and !is_attacking2 and !is_hit:
			enemy_sprite.play("melee1")
			melee1_hitbox.disabled = false
		elif is_attacking2 and !is_hit:
			enemy_sprite.play("melee2")
			melee2_hitbox.disabled = false
		elif is_hit:
			enemy_sprite.play("hurt")
		else:
			enemy_sprite.play("idle")

func _on_animation_finished():
	if curr_state == states.DYING:
		curr_state = states.EDIBLE

	if is_attacking1 and !is_attacking2:
		is_attacking1 = false
		melee1_hitbox.disabled = true
		if position.distance_to(target_pos) < melee_range:
			is_attacking2 = true
	elif is_attacking2:
		is_attacking2 = false
		melee2_hitbox.disabled = true
	
	if is_hit:
		is_hit = false
		
