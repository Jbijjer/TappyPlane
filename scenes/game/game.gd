extends Node2D

var pipes_scene = preload("res://scenes/pipes/pipes.tscn")
var broken_glass_scene = preload("res://scenes/glass.tscn")
var flames_scene = preload("res://scenes/flame/flame.tscn")

@onready var pipes_holder = $PipesHolder
@onready var flames_holder = $FlamesHolder
@onready var spawn_u = $SpawnU
@onready var spawn_l = $SpawnL
@onready var spawn_timer = $PipesSpawnTimer
@onready var game_over_sound = $GameOverSound
@onready var plane_cb = $PlaneCB
@onready var flames_spawn_timer = $FlamesSpawnTimer

# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.set_score(0)
	GameManager.on_game_over.connect(on_game_over)
	GameManager.on_glass_breaks.connect(on_glass_breaks)
	spawn_pipes()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func spawn_pipes() -> void:
	var y_pos = randf_range(spawn_u.position.y, spawn_l.position.y)
	var new_pipes = pipes_scene.instantiate()
	
	new_pipes.position = Vector2(spawn_l.position.x, y_pos)
	pipes_holder.add_child(new_pipes)

	
func spawn_flames() -> void:
	var y_pos = randf_range(spawn_u.position.y, spawn_l.position.y)
	var new_flame = flames_scene.instantiate()
	
	new_flame.position = Vector2(spawn_l.position.x + 50, y_pos)
	flames_holder.add_child(new_flame)


func stop_scrolling() -> void:
	spawn_timer.stop()
	flames_spawn_timer.stop()
	for pipe in pipes_holder.get_children():
		pipe.set_process(false)
	for flame in flames_holder.get_children():
		flame.set_process(false)


func _on_spawn_timer_timeout():
	spawn_pipes()


func _on_flames_spawn_timer_timeout():
	spawn_flames()


func on_game_over():
	stop_scrolling()
	game_over_sound.play()


func on_glass_breaks(x, y) -> void:
	var glass = broken_glass_scene.instantiate()
	add_child(glass)
	
	glass.position.x = x
	glass.position.y = y
