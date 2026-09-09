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

# --- Tunable gameplay parameters ---
# Every value below is adjustable at runtime from the debug Settings screen
# (scenes/settings/), persisted to user://tuning.cfg, and described in
# TUNABLE_PARAMS below (single source of truth the Settings UI is built
# from). The consts are the defaults shown as a reminder in that UI and used
# by "reset to default"; the vars are what gameplay code actually reads.

const DRAGON_GRAVITY_DEFAULT: float = 1800.0
const DRAGON_POWER_DEFAULT: float = -480.0
const UNICORN_GRAVITY_DEFAULT: float = 520.0
const UNICORN_POWER_DEFAULT: float = -384.0
const DRAGON_SCROLL_SPEED_DEFAULT: float = 60.0
const UNICORN_SCROLL_SPEED_DEFAULT: float = 170.0
const SCROLL_SPEED_SMOOTHING_DEFAULT: float = 3.5

const PIPES_SPAWN_INTERVAL_DEFAULT: float = 1.35
const PIPES_GAP_MIN_Y_DEFAULT: float = 352.0
const PIPES_GAP_MAX_Y_DEFAULT: float = 526.0

const FLAMES_SPAWN_INTERVAL_DEFAULT: float = 1.35
const FLAMES_GAP_MIN_Y_DEFAULT: float = 352.0
const FLAMES_GAP_MAX_Y_DEFAULT: float = 526.0

var dragon_gravity: float = DRAGON_GRAVITY_DEFAULT
var dragon_power: float = DRAGON_POWER_DEFAULT
var unicorn_gravity: float = UNICORN_GRAVITY_DEFAULT
var unicorn_power: float = UNICORN_POWER_DEFAULT
var dragon_scroll_speed: float = DRAGON_SCROLL_SPEED_DEFAULT
var unicorn_scroll_speed: float = UNICORN_SCROLL_SPEED_DEFAULT
var scroll_speed_smoothing: float = SCROLL_SPEED_SMOOTHING_DEFAULT

var pipes_spawn_interval: float = PIPES_SPAWN_INTERVAL_DEFAULT
var pipes_gap_min_y: float = PIPES_GAP_MIN_Y_DEFAULT
var pipes_gap_max_y: float = PIPES_GAP_MAX_Y_DEFAULT

var flames_spawn_interval: float = FLAMES_SPAWN_INTERVAL_DEFAULT
var flames_gap_min_y: float = FLAMES_GAP_MIN_Y_DEFAULT
var flames_gap_max_y: float = FLAMES_GAP_MAX_Y_DEFAULT

# Data-driven description of every tunable above, consumed by
# scenes/settings/settings.gd to build the UI. `negate: true` means the
# stored value is negative (an upward impulse) but shown/edited as a
# positive "power" for a more intuitive slider.
const TUNABLE_PARAMS := [
	{"key": "dragon_gravity", "label": "Dragon — Gravité", "description": "Vitesse à laquelle le dragon tombe (accélération verticale).", "default": DRAGON_GRAVITY_DEFAULT, "min": 200.0, "max": 4000.0, "step": 10.0},
	{"key": "dragon_power", "label": "Dragon — Puissance de saut", "description": "Force de l'impulsion vers le haut à chaque tap.", "default": -DRAGON_POWER_DEFAULT, "min": 100.0, "max": 1200.0, "step": 10.0, "negate": true},
	{"key": "unicorn_gravity", "label": "Licorne — Gravité", "description": "Vitesse à laquelle la licorne tombe (accélération verticale).", "default": UNICORN_GRAVITY_DEFAULT, "min": 100.0, "max": 3000.0, "step": 10.0},
	{"key": "unicorn_power", "label": "Licorne — Puissance de saut", "description": "Force de l'impulsion vers le haut à chaque tap.", "default": -UNICORN_POWER_DEFAULT, "min": 100.0, "max": 1200.0, "step": 10.0, "negate": true},
	{"key": "dragon_scroll_speed", "label": "Dragon — Vitesse horizontale", "description": "Vitesse à laquelle le monde défile en forme dragon.", "default": DRAGON_SCROLL_SPEED_DEFAULT, "min": 20.0, "max": 400.0, "step": 5.0},
	{"key": "unicorn_scroll_speed", "label": "Licorne — Vitesse horizontale", "description": "Vitesse à laquelle le monde défile en forme licorne.", "default": UNICORN_SCROLL_SPEED_DEFAULT, "min": 20.0, "max": 400.0, "step": 5.0},
	{"key": "scroll_speed_smoothing", "label": "Transition de vitesse", "description": "Vitesse à laquelle le scroll accélère/ralentit au changement de forme. Plus haut = transition plus brusque.", "default": SCROLL_SPEED_SMOOTHING_DEFAULT, "min": 0.5, "max": 15.0, "step": 0.1},
	{"key": "pipes_spawn_interval", "label": "Tuyaux — Fréquence", "description": "Secondes entre chaque tuyau. Plus bas = plus fréquent.", "default": PIPES_SPAWN_INTERVAL_DEFAULT, "min": 0.3, "max": 4.0, "step": 0.05},
	{"key": "pipes_gap_min_y", "label": "Tuyaux — Hauteur min", "description": "Position Y minimale possible du passage.", "default": PIPES_GAP_MIN_Y_DEFAULT, "min": 100.0, "max": 700.0, "step": 5.0},
	{"key": "pipes_gap_max_y", "label": "Tuyaux — Hauteur max", "description": "Position Y maximale possible du passage.", "default": PIPES_GAP_MAX_Y_DEFAULT, "min": 100.0, "max": 700.0, "step": 5.0},
	{"key": "flames_spawn_interval", "label": "Flames — Fréquence", "description": "Secondes entre chaque flame. Plus bas = plus fréquent.", "default": FLAMES_SPAWN_INTERVAL_DEFAULT, "min": 0.3, "max": 4.0, "step": 0.05},
	{"key": "flames_gap_min_y", "label": "Flames — Hauteur min", "description": "Position Y minimale possible d'une flame.", "default": FLAMES_GAP_MIN_Y_DEFAULT, "min": 50.0, "max": 750.0, "step": 5.0},
	{"key": "flames_gap_max_y", "label": "Flames — Hauteur max", "description": "Position Y maximale possible d'une flame.", "default": FLAMES_GAP_MAX_Y_DEFAULT, "min": 50.0, "max": 750.0, "step": 5.0},
]

const TUNING_SAVE_PATH := "user://tuning.cfg"

const MILESTONES: Array[int] = [25, 50, 100, 200]

var _score: int = 0
var _high_score: int = 0
var _next_milestone_index: int = 0

var current_form: int = Form.DRAGON
var _current_scroll_speed: float = DRAGON_SCROLL_SPEED_DEFAULT

# Debug-only convenience so we can test flight feel / obstacles without dying
# constantly. Never exposed outside debug builds -- see game.gd, which only
# shows the toggle when OS.is_debug_build() is true.
var debug_invincible: bool = false

var game_scene: PackedScene = preload("res://scenes/game/game.tscn")
var main_scene: PackedScene = preload("res://scenes/main/main.tscn")
var settings_scene: PackedScene = preload("res://scenes/settings/settings.tscn")

func _ready() -> void:
	load_tuning()


func save_tuning() -> void:
	var cfg = ConfigFile.new()
	for param in TUNABLE_PARAMS:
		cfg.set_value("tuning", param.key, get(param.key))
	cfg.save(TUNING_SAVE_PATH)


func load_tuning() -> void:
	var cfg = ConfigFile.new()
	if cfg.load(TUNING_SAVE_PATH) != OK:
		return
	for param in TUNABLE_PARAMS:
		if cfg.has_section_key("tuning", param.key):
			set(param.key, cfg.get_value("tuning", param.key))

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
	var target = dragon_scroll_speed if current_form == Form.DRAGON else unicorn_scroll_speed
	_current_scroll_speed = lerp(_current_scroll_speed, target, clamp(delta * scroll_speed_smoothing, 0.0, 1.0))


func get_scroll_speed() -> float:
	return _current_scroll_speed


func get_gravity() -> float:
	return dragon_gravity if current_form == Form.DRAGON else unicorn_gravity


func get_power() -> float:
	return dragon_power if current_form == Form.DRAGON else unicorn_power


func switch_form() -> void:
	current_form = Form.UNICORN if current_form == Form.DRAGON else Form.DRAGON
	on_form_changed.emit(current_form)


func reset_form() -> void:
	current_form = Form.DRAGON
	_current_scroll_speed = dragon_scroll_speed


func toggle_debug_invincible() -> void:
	debug_invincible = not debug_invincible


func load_game_scene() -> void:
	get_tree().change_scene_to_packed(game_scene)
	
	
func load_main_scene() -> void:
	get_tree().change_scene_to_packed(main_scene)


func load_settings_scene() -> void:
	get_tree().change_scene_to_packed(settings_scene)

	
func save_score(content):
	var file = FileAccess.open("user://saved_data.sav", FileAccess.WRITE)
	file.store_16(content)

func load_score():
	var file = FileAccess.open("user://saved_data.sav", FileAccess.READ)
	if file == null:
		return null
	var content = file.get_16()	
	return content
