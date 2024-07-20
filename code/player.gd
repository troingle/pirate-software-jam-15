extends CharacterBody2D

var speed = 265
var accel = 40

var dir

var last_anim = "walk"

var hp = 2.5
var dead = false

var note_open = false
var note_content = ""
@onready var note_label = $CanvasLayer/Label

@onready var anim = $AnimationPlayer

@onready var raycast = $RayCast2D
@onready var raycast2 = $RayCast2D2
@onready var raycast3 = $RayCast2D3

@onready var bar = $"../LifeforceBar"
@onready var bar_visibility_timer = $BarVisibilityTimer

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
			
	if note_open:
		note_label.visible = true
		note_label.text = note_content
	else:
		note_label.visible = false
		
	if Input.is_action_just_pressed("left") or Input.is_action_just_pressed("right") or Input.is_action_just_pressed("up") or Input.is_action_just_pressed("down"):
		note_open = false
		

	if hp < 0:
		bar.visible = false
		dead = true
		print("Death")
	else:
		bar.scale.x = hp * 2.5
		bar.global_position = Vector2(global_position.x - (bar.scale.x / 2), global_position.y - 50)
		

func _on_punch_timer_timeout():
	if raycast.is_colliding():
		hurt_enemy(raycast)
	elif raycast2.is_colliding():
		hurt_enemy(raycast2)
	elif raycast3.is_colliding():
		hurt_enemy(raycast3)
		
func hurt_enemy(raycast):
	raycast.get_collider().hurt_particles.emitting = true
	raycast.get_collider().hp -= 1

func _on_bar_visibility_timer_timeout():
	bar.visible = false
