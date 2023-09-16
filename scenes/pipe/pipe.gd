extends Area2D

@onready var animated_sprite_2d = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if animated_sprite_2d.animation == "explode" && animated_sprite_2d.frame == 5:
		GameManager.on_glass_breaks.emit(animated_sprite_2d.global_position.x, animated_sprite_2d.global_position.y)
	
	
func _on_body_entered(body):	
	if body.is_in_group(GameManager.GROUP_PLANE) == true:
		animated_sprite_2d.play("explode")
		body.die()
