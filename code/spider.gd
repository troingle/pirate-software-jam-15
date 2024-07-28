extends CharacterBody2D

var golden = false

func _physics_process(delta):
	if golden:
		$Sprites/BackL/Leg.self_modulate = "#FFD700"
		$Sprites/BackL/LegThing/Leg.self_modulate = "#FFD700"
		$Sprites/BackR/Leg.self_modulate = "#FFD700"
		$Sprites/BackR/LegThing/Leg.self_modulate = "#FFD700"
		$Sprites/FrontL/Leg.self_modulate = "#FFD700"
		$Sprites/FrontL/LegThing/Leg.self_modulate = "#FFD700"
		$Sprites/FrontR/Leg.self_modulate = "#FFD700"
		$Sprites/FrontR/LegThing/Leg.self_modulate = "#FFD700"
		$Sprites/Body.self_modulate = "#FFD700"
		$AnimationPlayer.pause()
		$CollisionShape2D.disabled = true
	else:
		move_and_slide()
	
