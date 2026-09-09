extends Control

const TUNING_ROW_SCENE = preload("res://scenes/settings/tuning_row.tscn")

@onready var rows_container = $ScrollContainer/VBoxContainer

var _rows: Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	for param in GameManager.TUNABLE_PARAMS:
		var row = TUNING_ROW_SCENE.instantiate()
		rows_container.add_child(row)
		row.setup(param)
		_rows.append(row)


func _on_back_button_pressed():
	GameManager.load_main_scene()


func _on_reset_all_button_pressed():
	for i in range(_rows.size()):
		_rows[i].reset_to_default(GameManager.TUNABLE_PARAMS[i].default)
