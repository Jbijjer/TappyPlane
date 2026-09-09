extends Node

signal on_game_over
signal on_score_updated
signal on_glass_breaks
signal on_explode
signal on_milestone_reached(milestone: int)
signal on_near_miss(x: float, y: float)
signal on_form_changed(form: int)

const GROUP_PLANE: String = "plane"

enum Form { DRAGON, UNICORN }

# Per-form flight physics. Values are a first pass -- tune by feel.
const DRAGON_GRAVITY: float = 1800.0
const DRAGON_POWER: float = -400.0
const UNICORN_GRAVITY: float = 520.0  # -60% fall speed from original 1300.0
const UNICORN_POWER: float = -480.0

# Per-form scroll speed. Transitions are smoothed (see _process), not instant.
const DRAGON_SCROLL_SPEED: float = 60.0  # -50% from original 120.0
const UNICORN_SCROLL_SPEED: float = 170.0
const SCROLL_SPEED_SMOOTHING: float = 3.5

const MILESTONES: Array[int] = [25, 50, 100, 200]

var _score: int = 0
var _high_score: int = 0
var _next_milestone_index: int = 0

var current_form: int = Form.DRAGON
var _current_scroll_speed: float = DRAGON_SCROLL_SPEED

# Debug-only convenience so we can test flight feel / obstacles without dying
# constantly. Never exposed outside debug builds -- see game.gd, which only
# shows the toggle when OS.is_debug_build() is true.
var debug_invincible: bool = false

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


func _process(delta: float) -> void:
	var target = DRAGON_SCROLL_SPEED if current_form == Form.DRAGON else UNICORN_SCROLL_SPEED
	_current_scroll_speed = lerp(_current_scroll_speed, target, clamp(delta * SCROLL_SPEED_SMOOTHING, 0.0, 1.0))


func get_scroll_speed() -> float:
	return _current_scroll_speed


func get_gravity() -> float:
	return DRAGON_GRAVITY if current_form == Form.DRAGON else UNICORN_GRAVITY


func get_power() -> float:
	return DRAGON_POWER if current_form == Form.DRAGON else UNICORN_POWER


func switch_form() -> void:
	current_form = Form.UNICORN if current_form == Form.DRAGON else Form.DRAGON
	on_form_changed.emit(current_form)


func reset_form() -> void:
	current_form = Form.DRAGON
	_current_scroll_speed = DRAGON_SCROLL_SPEED


func toggle_debug_invincible() -> void:
	debug_invincible = not debug_invincible


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
