extends Control

@onready var label = $MC/Label
@onready var milestone_label = $MilestoneLabel
@onready var milestone_timer = $MilestoneTimer

# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.on_score_updated.connect(on_score_updated)
	GameManager.on_milestone_reached.connect(on_milestone_reached)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func on_score_updated() -> void:
	label.text = str(GameManager.get_score())


func on_milestone_reached(milestone: int) -> void:
	milestone_label.text = "%d pts !" % milestone
	milestone_label.show()
	SoundManager.play_sound(preload("res://assets/audio/score.wav"))
	milestone_timer.start()


func _on_milestone_timer_timeout():
	milestone_label.hide()
