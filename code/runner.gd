extends CharacterBody2D

@onready var player = $"../Player"
@onready var hurt_particles = $HurtEffect
@onready var anim = $AnimationPlayer
@onready var detector_object = $PlayerDetectors
@onready var golden_coll = $GoldenColl/CollisionShape2D

@export var speed = 160.0

@export var vertical = true
@export var dir = 1

@export var length = 1000
@export var rc_length = 1000

var detected = false
var punchHelper = 1

@export var hp = 5
var golden = false

var triggered = false
var hit = false
var start_pos

var bloodObj = preload("res://scenes/blood.tscn")

func _ready():
	start_pos = global_position
	
	$PlayerDetectors/DetectPlayer.target_position.x = rc_length
	$PlayerDetectors/DetectPlayer2.target_position.x = rc_length
	$PlayerDetectors/DetectPlayer3.target_position.x = rc_length
	$PlayerDetectors/DetectPlayer4.target_position.x = rc_length
	$PlayerDetectors/DetectPlayer5.target_position.x = rc_length
	
	if $"..".name == "7":
		visible = false
		$CollisionShape2D.disabled = true
		$GoldenColl/CollisionShape2D.disabled = true
		$StoneColl/CollisionShape2D.disabled = true

func _physics_process(delta):
	if not golden:
		if ($"..".name != "7" and raycasts_collide()) or ($"..".name == "7" and player.read):
			visible = true
			if vertical:
				velocity.y = speed * dir
			else:
				velocity.x = speed * dir
		if vertical:
			if global_position.y > start_pos.y + length * dir:
				queue_free()
		else:
			if global_position.x > start_pos.x + length * dir:
				queue_free()
				
		if $HurtSpot.global_position.distance_to(player.global_position) < 55 and not hit and visible:
			hit = true
			if $"..".name == "7":
				player.hp -= 5
			else:
				player.hp -= 2.4
			player.bar.visible = true
			player.runner_hit_sfx.play()
			player.bar_visibility_timer.start()
			player.show_damage_visually(true)
			
		if $"..".name == "7" and global_position.y < -740:
			if not player.fading_to_white:
				player.fading_to_white = true
				player.white_cover_anim.play("fade")
				player.remove_block_timer.start()
				player.explode_sfx.play()
			queue_free()
				
	else:
		golden_coll.disabled = false
		$Sprites/Body.self_modulate = "#FFD700"
		$Sprites/ShoulderL/ArmL.self_modulate = "#FFD700"
		$Sprites/ShoulderL/HandThingy/Sprite2D5.self_modulate = "#FFD700"
		$Sprites/ShoulderR/ArmR.self_modulate = "#FFD700"
		$Sprites/ShoulderR/HandThingy/Sprite2D5.self_modulate = "#FFD700"
		$Sprites/Head.self_modulate = "#FFD700"
	
	if not golden:
		move_and_slide()
		
func raycasts_collide():
	return $PlayerDetectors/DetectPlayer.is_colliding() or $PlayerDetectors/DetectPlayer2.is_colliding() or $PlayerDetectors/DetectPlayer3.is_colliding() or $PlayerDetectors/DetectPlayer4.is_colliding() or $PlayerDetectors/DetectPlayer5.is_colliding()
		
		
		
