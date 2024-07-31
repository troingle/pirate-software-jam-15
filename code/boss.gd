extends CharacterBody2D

@onready var player = $"../Player"
@onready var raycast = $RayCast2D
@onready var hurt_particles = $HurtEffect
@onready var anim = $AnimationPlayer

var speed = 236.0

var hp = 25
var golden = false

var bloodObj = preload("res://scenes/blood.tscn")

var active = false

@onready var bar = $"../BossBar"

func _physics_process(delta):
	if active:
		if hp > 0:
			look_at(player.global_position)
			var direction = (player.boss_target.global_position - global_position).normalized()
			velocity = direction * speed
			move_and_slide()
		else:
			var blood = bloodObj.instantiate()
			$"..".add_child(blood)
			blood.global_position = global_position
			blood.emitting = true
			player.boss_dead = true
			$"../BossBar".queue_free()
			queue_free()
	
	bar.scale.x = hp * 0.92
	bar.global_position = Vector2(global_position.x - (bar.scale.x / 2), global_position.y - 50)
	
func _on_human_punch_timer_timeout():
	if raycast.is_colliding() and not player.dead:
		player.hp -= 0.1
		player.play_hurt_sfx()
		player.bar.visible = true
		player.bar_visibility_timer.start()
		player.show_damage_visually(false)
