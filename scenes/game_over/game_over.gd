extends Control

@onready var game_over_label = $GameOverLabel
@onready var timer = $Timer
@onready var press_space_label = $PressSpaceLabel

var _can_press_space: bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.on_game_over.connect(on_game_over) # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _can_press_space == true:
		if Input.is_action_just_pressed("fly") == true:
			GameManager.load_main_scene()
	

func on_game_over() -> void:
	show()
	timer.start()
	
	
func run_sequence() -> void:
	game_over_label.hide()
	press_space_label.show()
	GameManager.save(GameManager.get_high_score())
	_can_press_space = true
	
	

func _on_timer_timeout():
	run_sequence() # Replace with function body.
