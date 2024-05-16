# add to character scenes (+collisionShape), used for hit detection (being damaged)
extends Area2D

@onready var timer = $Timer # i-frame timer
var is_invincible: bool = false

signal damage_taken

func _on_area_entered(area):
	if area.name == "hitboxes" and !is_invincible:
		timer.start(1.05)
		damage_taken.emit()
		is_invincible = true

func _on_timer_timeout():
	is_invincible = false
