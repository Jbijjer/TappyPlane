extends Node2D

const NEAR_MISS_MARGIN: float = 30.0

@onready var score_sound = $ScoreSound
@onready var area_2d = $Area2D
@onready var collision_shape = $Area2D/CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.x -= GameManager.get_scroll_speed() * delta


func _on_screen_exited():
	queue_free()


func player_scored() -> void:
	GameManager.increment_score()
	score_sound.play()


func _on_area_2d_body_entered(body):
	if body.is_in_group(GameManager.GROUP_PLANE) == true:
		player_scored()
		_check_near_miss(body)


func _check_near_miss(body) -> void:
	var half_height = collision_shape.shape.size.y / 2.0
	var local_y = area_2d.to_local(body.global_position).y
	if half_height - abs(local_y) <= NEAR_MISS_MARGIN:
		GameManager.on_near_miss.emit(body.global_position.x, body.global_position.y)
