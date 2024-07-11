# contains common enemy stats and behaviours
# to be inherited by enemy-specific scripts
extends CharacterBody2D

# enemy states
enum states {NEUTRAL, CHASE, ATTACK, DYING, EDIBLE}
var curr_state = states.NEUTRAL

# enemy stats
var max_health = 5
var health = 5
var SPEED = 150.0
var JUMP_VELOCITY = -250.0
var KNOCKBACK_POWER = 150.0 # applied to self

var is_hit: bool = false
var melee_range = 60
var is_attacking1: bool = false
var is_attacking2: bool = false

var can_interact_with: bool = false
var is_alive: bool = true
var can_be_eaten: bool = false

# enemy nodes and colliders
@onready var enemy_sprite = $AnimatedSprite2D
@onready var hurtbox = $enemy_hurtbox
@onready var hurtbox_collider = $enemy_hurtbox/hurtbox_collider
@onready var edible_hurtbox_collider = $enemy_hurtbox/edible_hurtbox_collider
@onready var detection_range = $enemy_detection_range
@onready var obs_detector = $AnimatedSprite2D/obstacle_detection
@onready var interactable = $interactable

# attack nodes
@onready var melee1_hitbox = $AnimatedSprite2D/hitboxes/hitbox_collider1
@onready var melee2_hitbox = $AnimatedSprite2D/hitboxes/hitbox_collider2

# player targetting nodes and variables
#@onready var target = %player
var target
var target_pos
var target_dir

var direction = 0 # direction to player, used to chase

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# initialize enemy stats, to be changed for unique enemies
func _init(_max_health = 5, _health = 5, _SPEED = 150.0):
	max_health = _max_health
	health = _health
	SPEED = _SPEED

func _ready():
	enemy_sprite.animation_finished.connect(_on_animation_finished)
	hurtbox.damage_taken.connect(_on_damage_taken)
	hurtbox.bite_taken.connect(_on_bite_taken)
	obs_detector.obstacle_detected.connect(_on_obstacle_detected)
	interactable.in_interact_range.connect(_on_in_interact_range)
	Events.interact_pressed.connect(start_interaction)

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
	
	# enemy action state control
	match curr_state:
		states.NEUTRAL:
			velocity.x = 0
		states.CHASE:
			find_player_direction()
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
			hurtbox_collider.disabled = true
			melee1_hitbox.disabled = true
			melee2_hitbox.disabled = true
		states.EDIBLE:
			velocity.x = 0
			edible_hurtbox_collider.disabled = false
	
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
	var player_nodes = get_tree().get_nodes_in_group("player")
	for node in player_nodes:
		# Check if the player node is an instanced scene
		if node.scene_file_path.is_empty():
			print("player node '%s' is not an instanced scene, skipped" % node.name)
			continue
		target = node
	
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
		enemy_sprite.play("death")
	if curr_state == states.EDIBLE:
		enemy_sprite.play("edible")
	
	if curr_state != states.DYING and curr_state != states.EDIBLE:
		if is_attacking1 and !is_attacking2 and !is_hit:
			enemy_sprite.play("melee1")
			if enemy_sprite.get_frame() == 1:
				melee1_hitbox.disabled = false
			else:
				melee1_hitbox.disabled = true
		elif is_attacking2 and !is_hit:
			enemy_sprite.play("melee2")
			if enemy_sprite.get_frame() == 1:
				melee2_hitbox.disabled = false
			else:
				melee2_hitbox.disabled = true
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
		

# check if player is within interaction range
func _on_in_interact_range(in_range):
	if in_range:
		can_interact_with = true
	else:
		can_interact_with = false

# start interaction with enemy TODO - limit interaction if dead
func start_interaction():
	if can_interact_with:
		print("wow interaction wow")

# save data related to enemy
func save():
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : global_position.x,
		"pos_y" : global_position.y,
		"current_health" : health,
		"max_health" : max_health,
		"curr_state" : curr_state
	}
	return save_dict
