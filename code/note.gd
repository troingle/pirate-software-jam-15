extends Sprite2D

@export var content = "Lorem ipsum dolor"
@export var date = "15th of August, 1536"

@onready var player = $"../../Player"

func _process(delta):
	if get_global_mouse_position().distance_to(global_position) < 30 and Input.is_action_just_pressed("click"):
		player.note_content = date + "
		" + content
		player.note_open = true
