extends KinematicBody2D

var grid_pos:Vector2
var steps = 0

func _ready() -> void:
	Game.player = self

func _physics_process(_t:float) -> void:
	var dir := Vector2()
	if Input.is_action_pressed("up"):
		dir.y -= 1
	if Input.is_action_pressed("down"):
		dir.y += 1
	if Input.is_action_pressed("left"):
		dir.x -= 1
	if Input.is_action_pressed("right"):
		dir.x += 1
	dir = dir.normalized()
	if dir.length_squared() > 0.0:
		move_and_slide(dir * 100)
		var tile = Vector2(Game.TILE_SIZE, Game.TILE_SIZE)
		grid_pos = ((position - (tile / 2.0)) / tile).round()
		Game.map.overlay.update = true
		
