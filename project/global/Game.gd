extends Node

const player_scene = preload("res://Player.tscn") # grid locked player
const playerf_scene = preload("res://Player_free.tscn") # free movement experimental
const TILE_SIZE = 20

var player
var map

var player_spawned = false

func spawn_player(pos:Vector2) -> void:
	if player_spawned: return
	player = player_scene.instance()
	add_child(player)
	player.grid_pos = pos
	player.position = (player.grid_pos * TILE_SIZE) + Vector2(TILE_SIZE/2.0, TILE_SIZE/2.0)
	player_spawned = true

func _input(event) -> void:
	if event.is_action_pressed("quit"):
		get_tree().quit()
