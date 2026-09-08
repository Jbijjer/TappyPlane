extends ParallaxBackground

# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.on_game_over.connect(on_game_over)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	scroll_offset.x += GameManager.get_scroll_speed() * delta * -1

func on_game_over() -> void:
	set_process(false)
