extends Control

var data = {highscore = 0}

@onready var high_score_label_2 = $MC/HB/HighScoreLabel2
@onready var settings_button = $SettingsButton

# Called when the node enters the scene tree for the first time.
func _ready():
	var high_score = GameManager.load_score()
	if high_score != null:
		high_score_label_2.text = str(high_score)
	else:
		high_score_label_2.text = "0"
	settings_button.visible = OS.is_debug_build()


func _on_settings_button_pressed():
	GameManager.load_settings_scene()


# Unlike gameplay's flight tap (which polls Input directly so it never
# misses a frame), the "tap to start" trigger uses _unhandled_input: Godot
# marks the event handled when a UI Control (like the Settings button)
# consumes it first, so it naturally never fires when tapping a button.
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("fly"):
		GameManager.load_game_scene()

