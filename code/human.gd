extends CharacterBody2D

@onready var player = $"../Player"
@onready var raycast = $RayCast2D
@onready var hurt_particles = $HurtEffect
@onready var anim = $AnimationPlayer
@onready var golden_coll = $GoldenColl/CollisionShape2D

@export var speed = 160.0
@export var detect_range = 500

var detected = false
var punchHelper = 1

@export var hp = 5
var golden = false

var bloodObj = preload("res://scenes/blood.tscn")

func _physics_process(delta):
	if not golden:
		if hp > 0:
			if detected:
				look_at(player.global_position)
				velocity = Vector2(1, 0).rotated(rotation) * speed
				
			elif global_position.distance_to(player.global_position) < detect_range:
				detected = true
				
			if global_position.distance_to(player.global_position) > 50:
				move_and_slide()
		else:
			var blood = bloodObj.instantiate()
			$"..".add_child(blood)
			blood.global_position = global_position
			blood.emitting = true
			queue_free()
	else:
		golden_coll.disabled = false
		$Sprites/Body.self_modulate = "#FFD700"
		$Sprites/ShoulderL/ArmL.self_modulate = "#FFD700"
		$Sprites/ShoulderL/Elbow/LowerArmL.self_modulate = "#FFD700"
		$Sprites/ShoulderL/Elbow/HandThingy/HandR.self_modulate = "#FFD700"
		$Sprites/ShoulderR/ArmR.self_modulate = "#FFD700"
		$Sprites/ShoulderR/Elbow/LowerArmR.self_modulate = "#FFD700"
		$Sprites/ShoulderR/Elbow/HandThingy/HandL.self_modulate = "#FFD700"
		$Sprites/Head.self_modulate = "#FFD700"
		
		
func _on_human_punch_timer_timeout():
	punchHelper += 1
	if punchHelper % 2 == 0 and raycast.is_colliding() and not golden and not player.dead and global_position.distance_to(player.global_position) < 60:
		player.hp -= 0.2
		player.bar.visible = true
		player.bar_visibility_timer.start()
		player.show_damage_visually(false)
