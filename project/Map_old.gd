extends Node2D

const wall_collision = preload("res://wall_collision.tscn")
const tile_scene = preload("res://tile.tscn")
const player_scene = preload("res://Player.tscn")

const map_width = 100
const map_height = 100
const tile_size = 20

const local_area_x = 12
const local_area_y = 8

var update_vision = true

var player
var map:Array = []

func _ready():
	initialize_map()
	map_clean_diagonals()
	map_clean_orphans()
	player_spawner()
	spawn_tiles_around_player()
	
func initialize_map() -> void:
	randomize()
	for x in range (map_width):
		map.append([])
		for y in range (map_height):
			var tile:Dictionary = {
				"node": false,
				"solid": false,
				"last_seen": -1,
				"visible": false
			}
			if randf() > 0.75: 
				tile.solid = true
			if x == 0 or x == map_width-1 or y == 0 or y == map_height-1:
				tile.solid = true
			
			map[x].append(tile)

func spawn_tile(x:int, y:int) -> void:
	
	if x < 0: return
	if x > map_width-1: return
	if y < 0: return
	if y > map_height-1: return
	
	var tile_node = tile_scene.instance()
	map[x][y].node = tile_node
	add_child(tile_node)
	tile_node.position = Vector2(x*tile_size, y*tile_size)
	if map[x][y].solid:
		map[x][y].node.texture = load("res://img/solid.png")
		map[x][y].node.get_node("StaticBody2D/CollisionShape2D").disabled = false
	else:
		map[x][y].node.texture = load("res://img/eigengrau.png")
		map[x][y].node.get_node("StaticBody2D/CollisionShape2D").disabled = true
	
func despawn_tile(x:int, y:int) -> void:
	
	if x < 0: return
	if x > map_width-1: return
	if y < 0: return
	if y > map_height-1: return
	
	if typeof(map[x][y].node) == TYPE_BOOL: 
		print ("typeof fail, X: ", x, " Y: ", y)
		return
	
	#print("X: ", x, "Y: ", y, "  REMOVING...")
	remove_child(map[x][y].node)
	map[x][y].node = false

func update_map_visibility(move_dir:Vector2) -> void:
	update_vision = true
	
	if move_dir == Vector2.UP or move_dir == Vector2.DOWN:
		var startx:int = int(player.grid_pos.x) - local_area_x
		var endx:int = int(player.grid_pos.x) + local_area_x
		for x in range (startx, endx+1):
			var y:int = int(player.grid_pos.y - move_dir.y) - int(local_area_y * move_dir.y)
			despawn_tile(x, y)
			y = int(player.grid_pos.y) + int(local_area_y * move_dir.y)
			spawn_tile(x, y)

	if move_dir == Vector2.LEFT or move_dir == Vector2.RIGHT:
		var starty:int = int(player.grid_pos.y) - local_area_y
		var endy:int = int(player.grid_pos.y) + local_area_y
		for y in range (starty, endy+1):
			var x:int = int(player.grid_pos.x - move_dir.x) - int(local_area_x * move_dir.x)
			despawn_tile(x, y)
			x = int(player.grid_pos.x) + int(local_area_x * move_dir.x)
			spawn_tile(x, y)

func set_tile_visibility(tile:Dictionary, v:bool, steps:int) -> void:
	if typeof(tile.node) != TYPE_BOOL:
		tile.node.get_node("overlay").visible = !v
		if v:
			tile.last_seen = steps
		
		var opacity:float
		if tile.last_seen > -1:
			opacity = clamp(steps - tile.last_seen, 0.0, 100.0) / 100.0
		else:
			opacity = 1.0
		
		if opacity < 0.3 and opacity > 0.0: opacity = 0.3
		elif opacity < 0.5 and opacity > 0.3: opacity = 0.5
		elif opacity < 0.75 and opacity > 0.5: opacity = 0.75
		elif opacity > 0.75: opacity = 1.0
		
		tile.node.get_node("overlay").modulate = Color(1,1,1,opacity)

func convert_to_tile_pos(pos) -> Vector2:
	return ((pos - Vector2(tile_size/2, tile_size/2)) / tile_size).round()

func player_spawner():
	var player_x = randi() % map_width
	var player_y = randi() % map_height
	while map[player_x][player_y].solid:
		player_x = randi() % map_width
		player_y = randi() % map_height
	
	player = player_scene.instance()
	add_child(player)
	player.grid_pos = Vector2(player_x, player_y)
	player.position = (player.grid_pos*tile_size) + Vector2(tile_size/2.0, tile_size/2.0)

func spawn_tiles_around_player():
	var startx = max(player.grid_pos.x - local_area_x, 0)
	var endx = min(player.grid_pos.x + local_area_x, map_width-1)
	var starty = max(player.grid_pos.y - local_area_y, 0)
	var endy = min(player.grid_pos.y + local_area_y, map_height-1)
	
	for x in range (startx, endx+1):
		for y in range (starty, endy+1):
			spawn_tile(x,y)
			#print("X: ", x, "Y: ", y, "  SPAWNING...")

func map_clean_diagonals():
	var errors = 0
	for x in range (1, map_width-2):
		for y in range (1, map_height-2):
			if map[x][y].solid:
				# top left
				if map[x-1][y-1].solid:
					if not map[x-1][y].solid and not map[x][y-1].solid:
						errors += 1
						var z = randi() % 3
						if z == 0:
							map[x][y].solid = false
						elif z == 1:
							map[x-1][y].solid = true 
						elif z == 2:
							map[x][y-1].solid = true
				
				# top right
				if map[x+1][y-1].solid:
					if not map[x+1][y].solid and not map[x][y-1].solid:
						errors += 1
						var z = randi() % 3
						if z == 0:
							map[x][y].solid = false
						elif z == 1:
							map[x+1][y].solid = true
						elif z == 2:
							map[x][y-1].solid = true
				
				# bottom left
				if map[x-1][y+1].solid:
					if not map[x-1][y].solid and not map[x][y+1].solid:
						errors += 1
						var z = randi() % 3
						if z == 0:
							map[x][y].solid = false
						elif z == 1:
							map[x-1][y].solid = true
						elif z == 2:
							map[x][y+1].solid = true
				
				# bottom right
				if map[x+1][y+1].solid:
					if not map[x+1][y].solid and not map[x][y+1].solid:
						errors += 1
						var z = randi() % 3
						if z == 0:
							map[x][y].solid = false
						elif z == 1:
							map[x+1][y].solid = true
						elif z == 2:
							map[x][y+1].solid = true
	if errors > 0:
		map_clean_diagonals()

func map_clean_orphans():
	for x in range (1, map_width-2):
		for y in range (1, map_height-2):
			if map[x][y].solid:
				if not map[x+1][y].solid and not map[x-1][y].solid and not map[x][y-1].solid and not map[x][y+1].solid:
					map[x][y].solid = false


var ray_dir := Vector2.UP
var vision_tiles:Array = []
func _physics_process(_t:float) -> void:
	
	$CanvasLayer/FPS.text = str(Engine.get_frames_per_second()) + " fps"
	$CanvasLayer/vision_update.text = str(update_vision)
	if update_vision:
		
		var time = OS.get_ticks_usec()
		for x in range (map.size()):
			for y in range (map[x].size()):
				set_tile_visibility(map[x][y], false, player.steps)
		
		var space_state = get_world_2d().direct_space_state
		
		for i in range (360):
			ray_dir = ray_dir.rotated(2 * PI / (i+1))
			
			var ray_start = player.grid_pos * tile_size + (Vector2(tile_size/2, tile_size/2))
			var ray_end = ray_start + (ray_dir * tile_size * local_area_x)
			var result = space_state.intersect_ray(ray_start, ray_end, [player])
			
			var length:float
			var coord:Vector2
			
			if result.empty():
				$DebugObject.position = ray_end
				length = (ray_start - ray_end).length()
			else:
				$DebugObject.position = result.position
				length = (ray_start - result.position).length()
				coord = convert_to_tile_pos(result.position - result.normal)
				set_tile_visibility(map[coord.x][coord.y], true, player.steps)
			
			var dist:float = 0.0
			var pos:Vector2 = ray_start
			while dist < length:
				coord = convert_to_tile_pos(pos)
				if coord.x < 0 or coord.y < 0 or coord.x > map_width-1 or coord.y > map_height-1:
					# watch out for out of bounds map coords
					break
				set_tile_visibility(map[coord.x][coord.y], true, player.steps)
				pos += ray_dir*tile_size
				dist += tile_size
		
		$CanvasLayer/vision_update_time.text = str(OS.get_ticks_usec() - time) + " microseconds"
		
		update_vision = false
