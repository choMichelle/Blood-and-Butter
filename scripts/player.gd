extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -300.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var is_attacking: bool = false

# get player nodes
@onready var animated_sprite = $AnimatedSprite2D
@onready var hitbox = $hitbox/hitbox_collider

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		
	if Input.is_action_just_pressed("melee_attack"):
		is_attacking = true

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("move_left", "move_right")
	
	play_animations(direction)
	
	# flip sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
		
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

# handles changing animations
func play_animations(direction):
	if is_attacking:
		animated_sprite.play("melee1")
		hitbox.disabled = false
	else:
		animated_sprite.play("idle")


func _on_animated_sprite_2d_animation_finished():
	if is_attacking:
		is_attacking = false
		hitbox.disabled = true
