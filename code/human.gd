extends CharacterBody2D

@onready var player = $"../Player"
@onready var raycast = $RayCast2D
@onready var hurt_particles = $HurtEffect

@export var speed = 160.0
@export var detect_range = 500

var detected = false
var punchHelper = 1

@export var hp = 5
var golden = false

var bloodObj = preload("res://scenes/blood.tscn")

func _physics_process(delta):
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
		
	
func _on_human_punch_timer_timeout():
	punchHelper += 1
	if punchHelper % 2 == 0 and raycast.is_colliding():
		player.hp -= 0.3
		player.bar.visible = true
		player.bar_visibility_timer.start()
