extends CharacterBody2D

const MAX_HEALTH = 10
var health = 10
@onready var hurtbox = $enemy_hurtbox

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	# process damage taken
	if hurtbox.is_hit == true && health > 0:
		health -= 1
		hurtbox.is_hit = false
		
	print(health)


