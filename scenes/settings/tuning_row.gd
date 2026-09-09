extends VBoxContainer

@onready var name_label = $NameLabel
@onready var desc_label = $DescLabel
@onready var slider = $HB/Slider
@onready var value_label = $HB/ValueLabel

var _key: String
var _negate: bool = false

# config keys: key, label, description, default, min, max, step, negate (optional)
func setup(config: Dictionary) -> void:
	_key = config.key
	_negate = config.get("negate", false)

	name_label.text = config.label
	desc_label.text = "%s (défaut : %s)" % [config.description, _format(config.default)]

	slider.min_value = config.min
	slider.max_value = config.max
	slider.step = config.step

	var current = GameManager.get(_key)
	if _negate:
		current = -current
	slider.value = current
	_update_value_label(current)

	slider.value_changed.connect(_on_value_changed)
	slider.drag_ended.connect(_on_drag_ended)


func _on_value_changed(value: float) -> void:
	GameManager.set(_key, -value if _negate else value)
	_update_value_label(value)


func _on_drag_ended(_value_changed: bool) -> void:
	GameManager.save_tuning()


func reset_to_default(default_value: float) -> void:
	slider.value = default_value
	GameManager.save_tuning()


func _update_value_label(value: float) -> void:
	value_label.text = _format(value)


func _format(value: float) -> String:
	return str(snapped(value, 0.01))
