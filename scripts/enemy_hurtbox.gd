# add to enemy scenes (+collisionShape), used for hit detection
extends Area2D

@onready var timer = $Timer
var is_hit: bool = false
var is_invincible: bool = false

func _on_area_entered(area):
	if area.name == "hitbox" && !is_invincible:
		timer.start(1.25) #i-frame timer
		is_hit = true
		is_invincible = true

func _on_timer_timeout():
	is_invincible = false
