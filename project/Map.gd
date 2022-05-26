extends TileMap

# tile types
const EMPTY = 3
const SOLID = 6
const ICE = 4

# other consts
const MAP_WIDTH = 96
const MAP_HEIGHT = 54

# overlay node
onready var overlay = $Overlay

func _init():
	Game.map = self

func tile2world(pos:Vector2) -> Vector2:
	return Vector2(pos.x*Game.TILE_SIZE, pos.y*Game.TILE_SIZE) + Vector2(Game.TILE_SIZE/2.0, Game.TILE_SIZE/2.0)

func _input(e) -> void:
	if Input.is_action_just_pressed("generate"):
		generate()

func _ready():
	# Initialize map
	randomize()
	
	var generate = false
	if generate: generate()
	else:
		Game.spawn_player(Vector2(8, 47))
	
func generate() -> void:
	for x in range (MAP_WIDTH):
		for y in range (MAP_HEIGHT):
			set_cell(x, y, EMPTY)
			if randf() > 0.75: 
				set_cell(x, y, SOLID)
			if x == 0 or x == MAP_WIDTH-1 or y == 0 or y == MAP_HEIGHT-1:
				set_cell(x, y, SOLID)
	
	var padding = 12
	var pos:Vector2
	pos.x = (randi() % (MAP_WIDTH  - padding*2)) + padding
	pos.y = (randi() % (MAP_HEIGHT - padding*2)) + padding
	Game.spawn_player(pos)
	
	var center := Vector2(MAP_WIDTH / 2, MAP_HEIGHT / 2)
	var towards_center = (center - pos).normalized()
	var special_point = (pos - (towards_center*8)).round()
	
	special_point = ((special_point - pos).rotated(-PI/4.0) + pos)
	for i in range (40):
		set_cellv(special_point.round(), SOLID)
		$DebugMapGen.points.append(tile2world(special_point))
		
		var away = special_point + (special_point - pos).normalized()
		set_cellv(away.round(), SOLID)
		$DebugMapGen.points.append(tile2world(away))
		
		
		special_point = ((special_point - pos).rotated(PI/80.0) + pos)
	$DebugMapGen.update()
	

	# Clean Diagonals (new function bc called multiple times in cleanup process)
	clean_diagonals()
		
	# Remove Orphans
	for x in range (1, MAP_WIDTH-2):
		for y in range (1, MAP_HEIGHT-2):
			if get_cell(x,y) == SOLID:
				if not get_cell(x+1,y) == SOLID and not get_cell(x-1,y) == SOLID and not get_cell(x,y-1) == SOLID and not get_cell(x,y+1) == SOLID:
					set_cell(x, y, EMPTY)
	
	# Make Ice
	while false:
		for _loop in range (20):
			var empty_list = get_used_cells_by_id(EMPTY)
			var ice_coord = empty_list[randi() % empty_list.size()]
			set_cellv(ice_coord, ICE)
			ice_recursive(ice_coord, 0)
	
	# Spawn Player
#	var empty_list = get_used_cells_by_id(EMPTY)
#	var player_coord = empty_list[randi() % empty_list.size()]
#	Game.spawn_player(player_coord.x, player_coord.y)
	
	update_dirty_quadrants() # updates collision this frame; builtin tilemap function.
	update_bitmask_region(Vector2.ZERO, Vector2(MAP_WIDTH,MAP_HEIGHT))

func get_nearby_empties(coord:Vector2) -> Array:
	var nearby_empties:Array = []
	if get_cell(coord.x, coord.y-1) == EMPTY:
		nearby_empties.append(Vector2(coord.x, coord.y-1))
	if get_cell(coord.x, coord.y+1) == EMPTY:
		nearby_empties.append(Vector2(coord.x, coord.y+1))
	if get_cell(coord.x-1, coord.y) == EMPTY:
		nearby_empties.append(Vector2(coord.x-1, coord.y))
	if get_cell(coord.x+1, coord.y) == EMPTY:
		nearby_empties.append(Vector2(coord.x+1, coord.y))
	return nearby_empties

func ice_recursive(coord:Vector2, loopcount:int) -> void:
	for tile in get_nearby_empties(coord):
		set_cellv(tile, ICE)
		if loopcount < 4:
			ice_recursive(tile, loopcount+1)

func clean_diagonals() -> void:
	var errors = 0
	for x in range (1, MAP_WIDTH-2):
		for y in range (1, MAP_HEIGHT-2):
			if get_cell(x,y) == SOLID:
				# top left
				if get_cell(x-1,y-1) == SOLID:
					if not get_cell(x-1,y) == SOLID and not get_cell(x,y-1) == SOLID:
						errors += 1
						var z = randi() % 3
						if   z == 0: set_cell(x,   y, EMPTY)
						elif z == 1: set_cell(x-1, y, SOLID)
						else:        set_cell(x, y-1, SOLID)
				
				# top right
				if get_cell(x+1,y-1) == SOLID:
					if not get_cell(x+1,y) == SOLID and not get_cell(x,y-1) == SOLID:
						errors += 1
						var z = randi() % 3
						if   z == 0: set_cell(x,   y, EMPTY)
						elif z == 1: set_cell(x+1, y, SOLID)
						else:        set_cell(x, y-1, SOLID)
				
				# bottom left
				if get_cell(x-1,y+1) == SOLID:
					if not get_cell(x-1,y) == SOLID and not get_cell(x,y+1) == SOLID:
						errors += 1
						var z = randi() % 3
						if   z == 0: set_cell(x,   y, EMPTY)
						elif z == 1: set_cell(x-1, y, SOLID)
						else:        set_cell(x, y+1, SOLID)
				
				# bottom right
				if get_cell(x+1,y+1) == SOLID:
					if not get_cell(x+1,y) == SOLID and not get_cell(x,y+1) == SOLID:
						errors += 1
						var z = randi() % 3
						if   z == 0: set_cell(x,   y, EMPTY)
						elif z == 1: set_cell(x+1, y, SOLID)
						else:        set_cell(x, y+1, SOLID)
	if errors > 0:
		clean_diagonals()
