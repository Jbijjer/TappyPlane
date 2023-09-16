extends Control

var data = {highscore = 0}

@onready var high_score_label_2 = $MC/HB/HighScoreLabel2

# Called when the node enters the scene tree for the first time.
func _ready():
	var high_score = GameManager.load_score()
	if high_score != null:
		high_score_label_2.text = str(high_score)
	else:
		high_score_label_2.text = "0"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("fly") == true:
		GameManager.load_game_scene()

