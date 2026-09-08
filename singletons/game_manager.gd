extends Node

signal on_game_over
signal on_score_updated
signal on_glass_breaks
signal on_explode
signal on_milestone_reached(milestone: int)
signal on_near_miss(x: float, y: float)

const GROUP_PLANE: String = "plane"

const BASE_SCROLL_SPEED: float = 120.0
const SCROLL_SPEED_PER_POINT: float = 1.5
const MAX_SCROLL_SPEED: float = 260.0

const BASE_SPAWN_INTERVAL: float = 1.35
const SPAWN_INTERVAL_PER_POINT: float = 0.01
const MIN_SPAWN_INTERVAL: float = 0.7

const MILESTONES: Array[int] = [25, 50, 100, 200]

var _score: int = 0
var _high_score: int = 0
var _next_milestone_index: int = 0

var game_scene: PackedScene = preload("res://scenes/game/game.tscn")
var main_scene: PackedScene = preload("res://scenes/main/main.tscn")

func get_score() -> int:
	return _score


func get_high_score() -> int:
	return _high_score


func set_score(value: int) -> void:
	_score = value
	if _score > _high_score:
		_high_score = _score
	if value == 0:
		_next_milestone_index = 0
	while _next_milestone_index < MILESTONES.size() and _score >= MILESTONES[_next_milestone_index]:
		on_milestone_reached.emit(MILESTONES[_next_milestone_index])
		_next_milestone_index += 1
	on_score_updated.emit()

func increment_score() -> void:
	set_score(_score + 1)


func get_highest_milestone_reached() -> int:
	return MILESTONES[_next_milestone_index - 1] if _next_milestone_index > 0 else 0


func get_scroll_speed() -> float:
	return min(BASE_SCROLL_SPEED + float(_score) * SCROLL_SPEED_PER_POINT, MAX_SCROLL_SPEED)


func get_spawn_interval() -> float:
	return max(BASE_SPAWN_INTERVAL - float(_score) * SPAWN_INTERVAL_PER_POINT, MIN_SPAWN_INTERVAL)


func load_game_scene() -> void:
	get_tree().change_scene_to_packed(game_scene)
	
	
func load_main_scene() -> void:
	get_tree().change_scene_to_packed(main_scene)
	
	
func save_score(content):
	var file = FileAccess.open("user://saved_data.sav", FileAccess.WRITE)
	file.store_16(content)

func load_score():
	var file = FileAccess.open("user://saved_data.sav", FileAccess.READ)
	if file == null:
		return null
	var content = file.get_16()	
	return content
