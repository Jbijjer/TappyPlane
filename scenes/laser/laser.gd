extends Area2D

enum State { SAFE, WARNING, DEADLY }

const STATE_DURATIONS := {
	State.SAFE: 1.2,
	State.WARNING: 0.4,
	State.DEADLY: 0.5,
}

const SAFE_COLOR := Color(1, 1, 1, 0.25)
const WARNING_COLOR := Color(1, 0.8, 0.2, 0.6)
const DEADLY_COLOR := Color(1, 0.2, 0.2, 1.0)

@onready var sprite = $Sprite2D
@onready var collision_shape = $CollisionShape2D
@onready var blink_timer = $BlinkTimer

var _state: int = State.SAFE

# Called when the node enters the scene tree for the first time.
func _ready():
	_enter_state(State.SAFE)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.x -= GameManager.get_scroll_speed() * delta


func _on_screen_exited():
	queue_free()


func _enter_state(state: int) -> void:
	_state = state
	collision_shape.disabled = state != State.DEADLY
	match state:
		State.SAFE:
			sprite.modulate = SAFE_COLOR
		State.WARNING:
			sprite.modulate = WARNING_COLOR
		State.DEADLY:
			sprite.modulate = DEADLY_COLOR
	blink_timer.wait_time = STATE_DURATIONS[state]
	blink_timer.start()


func _on_blink_timer_timeout():
	_enter_state((_state + 1) % 3)


func _on_body_entered(body):
	if body.is_in_group(GameManager.GROUP_PLANE) == true and _state == State.DEADLY:
		body.die()
