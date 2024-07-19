extends Node2D

# i don't understand it either

func get_players_positions():
	var positions = []
	for player in get_tree().get_nodes_in_group("players"):
		positions.append(player.global_position)
	return positions

func geometric_median(points: Array) -> Vector2:
	var current_guess = points[0]
	var min_dist_sum = INF

	var step_size = 10.0
	var tolerance = 0.1

	while step_size > tolerance:
		var neighbors = [
			current_guess + Vector2(step_size, 0),
			current_guess - Vector2(step_size, 0),
			current_guess + Vector2(0, step_size),
			current_guess - Vector2(0, step_size),
		]
		
		for neighbor in neighbors:
			var dist_sum = 0.0
			for point in points:
				dist_sum += neighbor.distance_to(point)
			
			if dist_sum < min_dist_sum:
				min_dist_sum = dist_sum
				current_guess = neighbor
		
		step_size *= 0.5
	
	return current_guess

func _process(delta):
	var player_positions = get_players_positions()
	var median_position = geometric_median(player_positions)
	global_position = median_position
