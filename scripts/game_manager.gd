extends Node


var game_time = 0.0
var graze_count = 0
var is_playing = false


signal graze_updated(new_count)
signal time_updated(new_time)


func start_game() -> void:
	game_time = 0.0
	graze_count = 0
	is_playing = true


func stop_game() -> void:
	is_playing = false


func increment_graze() -> void:
	graze_count += 1
	graze_updated.emit(graze_count)


func update_time(delta) -> void:
	if is_playing:
		game_time += delta
		time_updated.emit(game_time)


func get_time() -> float:
	return game_time


func get_graze_count() -> int:
	return graze_count
