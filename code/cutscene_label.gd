extends Label

# don't ask

var count = 0

var appear = 4
var duration = 1

func _on_timer_timeout():
	count += 1
	if count == appear:
		visible = true
	elif count > appear + duration:
		queue_free()
