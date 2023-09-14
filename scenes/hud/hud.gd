extends Control

@onready var label = $MC/Label

# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.on_score_updated.connect(on_score_updated)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func on_score_updated() -> void:
	label.text = str(GameManager.get_score())
