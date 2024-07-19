extends CharacterBody2D

var speed = 300
var accel = 200

var dir

var last_anim = "walk"

@onready var anim = $AnimationPlayer
@onready var raycast = $RayCast2D

func _physics_process(delta):
	look_at(get_global_mouse_position())
	
	dir = Input.get_vector("left", "right", "up", "down")
	velocity.x = move_toward(velocity.x, speed * dir.x, accel)
	velocity.y = move_toward(velocity.y, speed * dir.y, accel)

	move_and_slide()

	if Input.is_action_pressed("quit"):
		get_tree().quit()
		
	if Input.is_action_pressed("space") and anim.current_animation != "punch":
		anim.play("punch")
		$PunchTimer.start()
		last_anim = "punch"
	elif anim.current_animation != "punch":
		if dir:
			anim.play("walk")
			last_anim = "walk"
		elif last_anim == "walk":
			anim.play("RESET")

func _on_punch_timer_timeout():
	if raycast.is_colliding():
		print("Hit enemy")
		raycast.get_collider().hp -= 1
