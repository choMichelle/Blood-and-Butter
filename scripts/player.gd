# player stats and controls
extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -300.0
const DASH_VELOCITY = 1500.0
const KNOCKBACK_POWER = 150.0
var max_health = 6
var health = 6

var can_move: bool = true # use to lock player in place

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

var is_eating: bool = false
var is_hit: bool = false

# get player nodes
@onready var animated_sprite = $AnimatedSprite2D
@onready var hurtbox = $hurtbox

# dash nodes
@onready var dash_timer = $dash_timer
@onready var dash_particles = $AnimatedSprite2D/Particles2D

# attack nodes
@onready var melee1_hitbox = $AnimatedSprite2D/hitboxes/hitbox_collider1
@onready var melee2_hitbox = $AnimatedSprite2D/hitboxes/hitbox_collider2
@onready var melee_up_hitbox = $AnimatedSprite2D/hitboxes/hitbox_collider3

@onready var eat_hitbox = $AnimatedSprite2D/eat_hitbox/eat_collider

# custom signals
signal interact_pressed

func _ready():
	hurtbox.damage_taken.connect(_on_damage_taken)

func _physics_process(delta):
	#print(str(health) + "/" + str(max_health)) #TODO - delete
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if can_move:
		# handle interaction
		if Input.is_action_just_pressed("interact") and !is_dashing and is_on_floor():
			interact_pressed.emit()
		
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
		
		# handle eat
		if Input.is_action_just_pressed("special") and !is_dashing and is_on_floor():
			is_eating = true
		
		# movement
		if !is_eating: # conditions that lock player's movement
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
				animated_sprite.play("dash")
				if animated_sprite.scale.x == -1:
					velocity.x += DASH_VELOCITY * -1
				else:
					velocity.x += DASH_VELOCITY
				dash_timer.start()
				can_dash = false
				is_dashing = true
				dash_particles.emitting = true
			# reset dash
			if !is_dashing and is_on_floor():
				can_dash = true
		
			# flip sprite
			if direction > 0:
				animated_sprite.scale.x = 1
			elif direction < 0:
				animated_sprite.scale.x = -1
	
	move_and_slide()

	play_animations()

# handle taking damage
func _on_damage_taken(knockback_direction):
	if health > 0:
		#health -= 1
		velocity.x = knockback_direction * KNOCKBACK_POWER
		is_hit = true
		can_move = false
	if health == 0:
		can_move = false
		velocity.x = 0

# handle health recovery
func recover_health(hp_value):
	if health < max_health:
		health += hp_value

# handle increasing MAX_HEALTH
func add_max_health():
	max_health += 1

# handles changing animations
func play_animations():
	if health == 0 and is_on_floor():
		animated_sprite.play("death")
	if is_hit:
		animated_sprite.play("hurt")
	if !is_dashing and !is_hit:
		if is_attacking1:
			animated_sprite.play("melee1")
			if animated_sprite.get_frame() == 1:
				melee1_hitbox.disabled = false
			else:
				melee1_hitbox.disabled = true
		elif is_attacking2:
			animated_sprite.play("melee2")
			if animated_sprite.get_frame() == 1:
				melee2_hitbox.disabled = false
			else:
				melee2_hitbox.disabled = true
		elif is_attacking_up:
			animated_sprite.play("melee3")
			if animated_sprite.get_frame() == 1:
				melee_up_hitbox.disabled = false
			else:
				melee_up_hitbox.disabled = true
		elif is_eating:
			animated_sprite.play("eat")
			if animated_sprite.get_frame() == 4:
				eat_hitbox.disabled = false
			else:
				eat_hitbox.disabled = true
		elif velocity.y > 0:
			animated_sprite.play("fall")
		elif velocity.y < 0:
			animated_sprite.play("jump")
		elif velocity.x != 0:
			animated_sprite.play("walk")
		else:
			animated_sprite.play("idle")

# handle queued melee attack animations
func _on_animated_sprite_2d_animation_finished():
	if is_attacking1:
		is_attacking1 = false
		if queued_attack:
			is_attacking2 = true
			queued_attack = false
		
	elif is_attacking2:
		is_attacking2 = false
		if queued_attack:
			is_attacking1 = true
			queued_attack = false
		
	elif is_attacking_up:
		is_attacking_up = false
		if queued_attack:
			is_attacking1 = true
			queued_attack = false
	
	if is_eating:
		is_eating = false
	
	if is_hit:
		is_hit = false
		can_move = true

# turn off dash particles
func _on_dash_timer_timeout():
	is_dashing = false
	dash_particles.emitting = false

func save():
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x, # Vector2 is not supported by JSON
		"pos_y" : position.y,
		"current_health" : health,
		"max_health" : max_health
	}
	return save_dict


