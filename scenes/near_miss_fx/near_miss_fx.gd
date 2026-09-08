extends Node2D

@onready var animation_player = $AnimationPlayer
@onready var audio_stream_player = $AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	audio_stream_player.play()
	animation_player.play("flash")
