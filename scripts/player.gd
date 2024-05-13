# player stats and controls
extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -300.0
const DASH_VELOCITY = 1500.0

# movement bools
var can_doublejump: bool = false # controls when player can double jump
var can_dash: bool = true # controls when player can dash
var is_dashing: bool = false # used to limit movement during dash, also animation

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# attack bools
var is_attacking1: bool = false
var is_attacking2: bool = false
var is_attacking_up: bool = false
var queued_attack: bool = false

# get player nodes
@onready var player_node = $"."
@onready var animated_sprite = $AnimatedSprite2D

# dash nodes
@onready var dash_timer = $dash_timer
@onready var dash_particles = $AnimatedSprite2D/CPUParticles2D

# attack nodes
@onready var melee1_hitbox = $AnimatedSprite2D/hitboxes/hitbox_collider1
@onready var melee2_hitbox = $AnimatedSprite2D/hitboxes/hitbox_collider2
@onready var melee_up_hitbox = $AnimatedSprite2D/hitboxes/hitbox_collider3

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# handle attacking
	if Input.is_action_just_pressed("melee_attack") and !is_dashing:
		if velocity.y < 0 and !queued_attack:
			is_attacking_up = true
		elif is_attacking_up:
			queued_attack = true
		elif is_attacking2:
			queued_attack = true
		elif is_attacking1:
			queued_attack = true
		else:
			is_attacking1 = true
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		can_doublejump = true
		
	if Input.is_action_just_pressed("jump") and !is_on_floor() and can_doublejump:
		velocity.y = JUMP_VELOCITY
		can_doublejump = false
	
	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_axis("move_left", "move_right")
	
	if direction and !is_dashing:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	# handle dash
	if Input.is_action_just_pressed("dash") and can_dash:
		if animated_sprite.scale.x == -1:
			velocity.x += DASH_VELOCITY * -1
		else:
			velocity.x += DASH_VELOCITY
		can_dash = false
		is_dashing = true
		dash_particles.emitting = true
		dash_timer.start(0.32)
	
	play_animations()
	
	# flip sprite
	if direction > 0:
		animated_sprite.scale.x = 1
	elif direction < 0:
		animated_sprite.scale.x = -1

	move_and_slide()

# handles changing animations
func play_animations():
	if is_attacking1:
		animated_sprite.play("melee1")
		melee1_hitbox.disabled = false
	elif is_attacking2:
		animated_sprite.play("melee2")
		melee2_hitbox.disabled = false
	elif is_attacking_up:
		animated_sprite.play("melee3")
		melee_up_hitbox.disabled = false
	else:
		animated_sprite.play("idle")

# handle queued melee attack animations
func _on_animated_sprite_2d_animation_finished():
	if is_attacking1:
		is_attacking1 = false
		melee1_hitbox.disabled = true
		if queued_attack:
			is_attacking2 = true
			queued_attack = false
		
	elif is_attacking2:
		is_attacking2 = false
		melee2_hitbox.disabled = true
		if queued_attack:
			is_attacking1 = true
			queued_attack = false
		
	elif is_attacking_up:
		is_attacking_up = false
		melee_up_hitbox.disabled = true
		if queued_attack:
			is_attacking1 = true
			queued_attack = false

# reset dash after cooldown ends
func _on_dash_timer_timeout():
	is_dashing = false
	dash_particles.emitting = false
	if is_on_floor():
		can_dash = true
