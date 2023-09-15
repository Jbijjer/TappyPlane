extends Node

signal on_game_over
signal on_score_updated
signal on_glass_breaks
signal on_explode

const GROUP_PLANE: String = "plane"

var _score: int = 0
var _high_score: int = 0

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
	on_score_updated.emit()
	
func increment_score() -> void:
	set_score(_score + 1)


func load_game_scene() -> void:
	get_tree().change_scene_to_packed(game_scene)
	
	
func load_main_scene() -> void:
	get_tree().change_scene_to_packed(main_scene)
	
	
func save(content):
	var file = FileAccess.open("user://saved_data.sav", FileAccess.WRITE)
	file.store_16(content)

func load():
	var file = FileAccess.open("user://saved_data.sav", FileAccess.READ)
	if file == null:
		return null
	var content = file.get_16()	
	return content
