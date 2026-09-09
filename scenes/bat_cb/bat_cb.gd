extends CharacterBody2D

@onready var animation_player = $AnimationPlayer
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var transform_player = $TransformPlayer

# Placeholder tint until a real unicorn sprite exists.
const UNICORN_TINT := Color(1.0, 0.85, 1.0)
const DRAGON_TINT := Color(1, 1, 1)

var _dead: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.on_form_changed.connect(_on_form_changed)
	_apply_form_visual(GameManager.current_form)


func _process(delta):
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	velocity.y += GameManager.get_gravity() * delta

	fly()

	move_and_slide()

	if is_on_floor() == true:
		die()


func fly() -> void:
	if Input.is_action_just_pressed("fly") == true:
		velocity.y = GameManager.get_power()
		animation_player.play("fly")


func _on_form_changed(form: int) -> void:
	transform_player.play("transform")
	_apply_form_visual(form)


func _apply_form_visual(form: int) -> void:
	animated_sprite_2d.modulate = UNICORN_TINT if form == GameManager.Form.UNICORN else DRAGON_TINT


func die() -> void:
	if _dead == true:
		return
	_dead = true
	animated_sprite_2d.play("dead")
	GameManager.on_game_over.emit()
	set_physics_process(false)


func explode() -> void:
	animated_sprite_2d.play("dead")
	animated_sprite_2d.animation_finished.emit()
	die()
