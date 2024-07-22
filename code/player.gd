extends CharacterBody2D

var speed = 265
var accel = 40

var dir

var last_anim = "walk"

var hp = 2.5
var dead = false

var has_stone = false
var can_pick_up = true

var note_open = false
var note_content = ""
@onready var note_label = $CanvasLayer/Label

@onready var anim = $AnimationPlayer
@onready var camera = $Camera2D

@onready var raycast = $RayCast2D
@onready var raycast2 = $RayCast2D2
@onready var raycast3 = $RayCast2D3

@onready var bar = $"../LifeforceBar"
@onready var bar_visibility_timer = $BarVisibilityTimer

@onready var next_level = $"../NextLevel"

@onready var stone = $"../Stone"
@onready var stone_pos = $StonePos

@onready var pickup_timer = $PickupTimer

var shakeFade = 10.0

var rng = RandomNumberGenerator.new()

var strength = 0.0

func _ready():
	if $"..".name != "1" and $"..".name != "2":
		has_stone = true

func _physics_process(delta):
	look_at(get_global_mouse_position())
	
	dir = Input.get_vector("left", "right", "up", "down")
	velocity.x = move_toward(velocity.x, speed * dir.x, accel)
	velocity.y = move_toward(velocity.y, speed * dir.y, accel)
	
	if not dead:
		move_and_slide()

	if Input.is_action_pressed("quit"):
		get_tree().quit()
	
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
	
	if not has_stone:
		if Input.is_action_just_pressed("space") and anim.current_animation != "punch":
			anim.play("punch")
			$PunchTimer.start()
			last_anim = "punch"
		elif anim.current_animation != "punch":
			if dir:
				anim.play("walk")
				last_anim = "walk"
			elif last_anim == "walk":
				anim.play("RESET")
	else:
		anim.play("RESET")
			
	if note_open:
		note_label.visible = true
		note_label.text = note_content
	else:
		note_label.visible = false
		
	if anything_is_pressed():
		note_open = false
		
	if hp < 0:
		bar.visible = false
		dead = true
	else:
		bar.scale.x = hp * 2.5
		bar.global_position = Vector2(global_position.x - (bar.scale.x / 2), global_position.y - 50)
		
	if global_position.distance_to(next_level.global_position) < 75:
		get_tree().change_scene_to_file("res://scenes/" + str($"..".name.to_int() + 1) + ".tscn")
	
	if $"..".name != "1":
		if global_position.distance_to(stone.global_position) < 40 and can_pick_up:
			has_stone = true
	
	if has_stone:
		stone.global_position = stone_pos.global_position
		stone.look_at(get_global_mouse_position())
		if Input.is_action_just_pressed("space"):
			has_stone = false
			can_pick_up = false
			pickup_timer.start()
			stone.velocity = Vector2(1, 0).rotated(rotation) * stone.throw_speed
			
	if dead:
		$Sprites.visible = false
		if has_stone:
			stone.visible = false
		$CanvasLayer/DeathMsg.visible = true
		if Input.is_action_just_pressed("real_space"):
			get_tree().reload_current_scene()
			
	if strength > 0:
		strength = lerpf(strength, 0, shakeFade * delta)
		camera.offset = Vector2(rng.randf_range(-strength, strength), rng.randf_range(-strength, strength))
		

func _on_punch_timer_timeout():
	if not has_stone:
		if raycast.is_colliding():
			hurt_enemy(raycast)
		elif raycast2.is_colliding():
			hurt_enemy(raycast2)
		elif raycast3.is_colliding():
			hurt_enemy(raycast3)
		
func hurt_enemy(raycast):
	if not raycast.get_collider().golden:
		raycast.get_collider().hurt_particles.emitting = true
		raycast.get_collider().hp -= 1
		strength = 5.0

func _on_bar_visibility_timer_timeout():
	bar.visible = false

func _on_pickup_timer_timeout():
	can_pick_up = true
	
func show_damage_visually(severe):
	if severe:
		strength = 13.0
	else:
		strength = 7.0
		
func anything_is_pressed():
	return Input.is_action_just_pressed("left") or Input.is_action_just_pressed("right") or Input.is_action_just_pressed("up") or Input.is_action_just_pressed("down") or Input.is_action_just_pressed("click")
