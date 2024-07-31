extends CharacterBody2D

var speed = 265
var accel = 40

var dir

var last_anim = "walk"

var hp = 2.5
var dead = false

var read = false
var fading_to_white = false

var has_stone = false
var can_pick_up = true

var locked = false
var cutscene_finished = false
var stone_thrown = false
var boss_dead = false

var spin_dir = 1

var start_cutscene_finished = false

var music_started = false

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
@onready var next_timer = $NextTimer

@onready var white_cover_anim = $WhiteCoverAnim
@onready var remove_block_timer = $RemoveBlock
@onready var black_cover_anim = $BlackCoverAnim

@onready var spider = $"../Spider"
@onready var stone2 = $"../Stone2"
@onready var exit_stopper_coll = $"../ExitStopper/CollisionShape2D"

@onready var boss_target_parent = $"../TargetParent"
@onready var boss_target = $"../TargetParent/BossTarget"

@onready var start_timer = $StartTimer
@onready var start_explosion_timer = $StartExplosionTimer

@onready var hurt_sfx = $PlayerHurt
@onready var runner_hit_sfx = $RunnerHit
@onready var explode_sfx = $Explode


var shakeFade = 10.0

var rng = RandomNumberGenerator.new()

var strength = 0.0

func _ready():
	if $"..".name == "1":
		start_timer.start()
		start_explosion_timer.start()
	if $"..".name != "1" and $"..".name != "2":
		has_stone = true
	if $"..".name == "8":
		MusicObject.music.stop()
	black_cover_anim.play("fade_in")
	await get_tree().create_timer(0.2).timeout
	$CanvasLayer/FlashHelper.visible = false

func _physics_process(delta):
	look_at(get_global_mouse_position())
	if $"..".name == "8":
		boss_target_parent.global_position = global_position
		boss_target_parent.global_rotation += 0.05 * spin_dir
	
	if not locked:
		dir = Input.get_vector("left", "right", "up", "down")
	else:
		dir = Input.get_vector("", "", "", "")
	velocity.x = move_toward(velocity.x, speed * dir.x, accel)
	velocity.y = move_toward(velocity.y, speed * dir.y, accel)
	
	if not dead and !black_cover_anim.is_playing() and ($"..".name != "1" or start_cutscene_finished):
		move_and_slide()
	
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
		
	if note_open:
		if $"..".name == "7":
			if anything_is_pressed(true):
				note_open = false
				read = true
		elif anything_is_pressed(false):
			note_open = false
			read = true
		
	if hp < 0:
		bar.visible = false
		dead = true
	else:
		bar.scale.x = hp * 2.5
		bar.global_position = Vector2(global_position.x - (bar.scale.x / 2), global_position.y - 50)
		
	if global_position.distance_to(next_level.global_position) < 75:
		if !black_cover_anim.is_playing():
			black_cover_anim.play("fade_out")
			next_timer.start()
	
	if $"..".name != "1":
		if global_position.distance_to(stone.global_position) < 40 and can_pick_up:
			has_stone = true
	
	if has_stone:
		stone.global_position = stone_pos.global_position
		stone.look_at(get_global_mouse_position())
		if Input.is_action_just_pressed("real_space") and not locked and ($"..".name != "8" or cutscene_finished):
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
			
	if $"..".name == "8":
		if global_position.y < -837 and not cutscene_finished:
			locked = true
			exit_stopper_coll.disabled = false
			spider.velocity.y = 50
			if spider.global_position.y >= -1060 and not stone_thrown:
				stone_thrown = true
				stone2.velocity.y = 1700
			start_music()
		if boss_dead:
			$"../ProceedStopper".position.x -= 0.5
			$BossMusic.stop()
		if cutscene_finished:
			$"../ProceedStopper/CollisionShape2D".disabled = false
				
	if $"..".name == "1":
		if start_cutscene_finished:
			pass
		else:
			$Sprites.visible = false
		
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
		$HumanHurt.pitch_scale = rng.randf_range(0.6, 1)
		$HumanHurt.play()
		

func _on_bar_visibility_timer_timeout():
	bar.visible = false

func _on_pickup_timer_timeout():
	can_pick_up = true
	
func show_damage_visually(severe):
	if severe:
		strength = 13.0
	else:
		strength = 7.0
		
func anything_is_pressed(prevent_backtracking):
	if prevent_backtracking:
		return Input.is_action_pressed("left") or Input.is_action_pressed("right") or Input.is_action_just_pressed("up") or Input.is_action_pressed("down") or Input.is_action_just_pressed("click")
	else:
		return Input.is_action_just_pressed("left") or Input.is_action_just_pressed("right") or Input.is_action_just_pressed("up") or Input.is_action_just_pressed("down") or Input.is_action_just_pressed("click")

func _on_remove_block_timeout():
	$"../BackWall".queue_free()

func _on_spin_dir_change_timeout():
	spin_dir *= -1

func _on_next_timer_timeout():
	if $"..".name == "3":
		get_tree().change_scene_to_file("res://scenes/5.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/" + str($"..".name.to_int() + 1) + ".tscn")

func _on_start_timer_timeout():
	start_cutscene_finished = true
	$Sprites.visible = true
	$"../Pot".visible = false
	$"../Labels/Label".visible = true

func _on_start_explosion_timer_timeout():
	white_cover_anim.play("fade")
	explode_sfx.play()
	
func play_hurt_sfx():
	hurt_sfx.pitch_scale = rng.randf_range(0.6, 1)
	hurt_sfx.play()
	
func start_music():
	if not music_started:
		music_started = true
		$BossStartStrings.play()
		
