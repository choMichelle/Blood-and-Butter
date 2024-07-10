# add to character scenes (+collisionShape), used for hit detection (being damaged)
extends Area2D

@onready var hurtbox = $hurtbox_collider
@onready var timer = $Timer # i-frame timer
var is_invincible: bool = false

# define custom signals
signal damage_taken(knockback_direction)
signal bite_taken

func _on_area_entered(area):
	if area.is_in_group("hitboxes") and !is_invincible:
		timer.start(1.05)
		is_invincible = true
		
		# find direction the hit came from
		var knock_direction = 0
		var hit_direction = hurtbox.global_position.x - area.global_position.x
		if hit_direction > 0:
			knock_direction = 1
		if hit_direction < 0:
			knock_direction = -1
		
		damage_taken.emit(knock_direction)
		
	if area.is_in_group("eat_hitbox"):
		bite_taken.emit()

func _on_timer_timeout():
	is_invincible = false
