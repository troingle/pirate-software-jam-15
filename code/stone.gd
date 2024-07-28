extends CharacterBody2D

@onready var player = $"../Player"

var throw_speed = 1100.0
var friction_factor = 0.96

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	velocity.x *= friction_factor
	velocity.y *= friction_factor
			
	if velocity.x or velocity.y:
		if velocity.x > velocity.y:
			rotation_degrees += velocity.x / 100
		else:
			rotation_degrees += velocity.y / 100
			
	if player.has_stone or (velocity.x == 0 and velocity.y == 0):
		$CollisionShape2D.disabled = true
	else:
		$CollisionShape2D.disabled = false

	move_and_slide()

func _on_area_2d_body_entered(body):
	if $"..".name != "8" or name != "Stone2":
		if body.name == "StoneColl" and !player.has_stone and (velocity.x != 0 or velocity.y != 0) and body.get_parent().name != "Boss":
			body.get_parent().golden = true
			body.get_parent().anim.pause()
	else:
		body.golden = true
		player.locked = false
		player.cutscene_finished = true
		$"../Boss".active = true
		
		queue_free()
