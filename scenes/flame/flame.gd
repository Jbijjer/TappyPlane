extends Area2D

@onready var animation_player = $AnimatedSprite2D/AnimationPlayer
@onready var audio_stream_player = $AudioStreamPlayer


func _process(delta):
	position.x -= GameManager.get_scroll_speed() * delta

func _on_body_entered(body):
	if body.is_in_group(GameManager.GROUP_PLANE) == true:
		GameManager.increment_score()
		animation_player.play("death")
		visible = false
		

	
	
