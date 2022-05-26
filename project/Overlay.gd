extends TileMap

var update = true
var last_seen = []

var vision_limit = 12
var memory_step_length = 200

var debug = false

func _ready() -> void:
	for x in range (Game.map.MAP_WIDTH * 2):
		last_seen.append([])
		for y in range (Game.map.MAP_HEIGHT * 2):
			last_seen[x].append(-1)

func _physics_process(_t:float) -> void:
	if not update: return
	
	for tile in get_used_cells():
		var ls = last_seen[tile.x][tile.y]
		if ls == -1: continue
		var memory_distance = Game.player.steps - ls
		if memory_distance < memory_step_length:
			set_cellv(tile, 2) # somewhat visible
		elif memory_distance < memory_step_length*2:
			set_cellv(tile, 1) # more obscured
		#else:
		#	set_cellv(tile, 0) # completely unknown
	
	var space_state = get_world_2d().direct_space_state
		
	var ray_dir = Vector2.UP
	
	if debug:
		$DebugVision.points = []
		$DebugVision.lines = []
		
	var loops:int = 200
	for i in range (loops):
		ray_dir = ray_dir.rotated(2 * PI / loops)
		var ray_start = Game.player.grid_pos * Game.TILE_SIZE + (Vector2(Game.TILE_SIZE/2.0, Game.TILE_SIZE/2.0))
		#var ray_start = Game.player.position
		var ray_end = ray_start + (ray_dir * Game.TILE_SIZE * vision_limit)
		var result = space_state.intersect_ray(ray_start, ray_end, [Game.player])
		
		var length:float
		var coord:Vector2
			
		if debug:
			$DebugVision.lines.append([])
			$DebugVision.lines.back().append(ray_start)
		
		if result.empty():
			length = (ray_start - ray_end).length()
			
			if debug:
				$DebugVision.lines.back().append(ray_end)
		else:
			length = (ray_start - result.position).length()
			var point = result.position - (result.normal * (Game.TILE_SIZE / 4.0))
			if debug:
				$DebugVision.lines.back().append(result.position)
			coord = convert_to_overlay_tile_pos(point)
			
			if debug:
				var debugcoord = coord * (Game.TILE_SIZE / 2.0) + Vector2(Game.TILE_SIZE / 4.0, Game.TILE_SIZE / 4.0)
				#$DebugVision.points.append({"coord": point, "color": Color(1,0,0,1)})
				#$DebugVision.points.append({"coord": result.position, "color": Color(0,1,0,1)})
				$DebugVision.points.append({"coord": debugcoord, "color": Color(0,1,0,0.3)})
			
			make_tile_visible(coord.x, coord.y)
			
		var dist:float = 0.0
		var pos:Vector2 = ray_start
		while dist + 1.0 < length + (Game.TILE_SIZE/2.0):
			coord = convert_to_overlay_tile_pos(pos)
#			if coord.x < 0 or coord.y < 0 or coord.x > Game.map.MAP_WIDTH-1 or coord.y > Game.map.MAP_HEIGHT-1:
#				break # watch out for out of bounds map coords
			#$DebugVision.points.append(pos)
			if debug:
				var debugcoord = coord * (Game.TILE_SIZE / 2.0) + Vector2(Game.TILE_SIZE / 4.0, Game.TILE_SIZE / 4.0)
				$DebugVision.points.append({"coord": debugcoord, "color": Color(0,0,1,0.3)})
			make_tile_visible(coord.x, coord.y)
			pos += ray_dir * (Game.TILE_SIZE / 2.0)
			dist += (Game.TILE_SIZE / 2.0)
	
	update = false
	
	if debug:
		$DebugVision.update()

func convert_to_overlay_tile_pos(pos) -> Vector2:
	var quartertile = Vector2(Game.TILE_SIZE/4.0, Game.TILE_SIZE/4.0)
	return (((pos-quartertile) * 2) / Game.TILE_SIZE).round()
	#return ((pos - Vector2(Game.TILE_SIZE/4.0, Game.TILE_SIZE/4.0)) / Game.TILE_SIZE / 2.0).round()

func make_tile_visible(x:int, y:int) -> void:
	set_cell(x,y,3) # visible!
	last_seen[x][y] = Game.player.steps
