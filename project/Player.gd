extends Sprite

var grid_pos:Vector2
var steps = 0
var is_moving = false

var icelocked := Vector2.ZERO

var move_target:Vector2
var last_pos:Vector2

var interpolation_count:int = 0
const interpolation_total:int = 10

var dir_array:Array = []
var last_dir:Vector2

const text2vec = {
	"up": Vector2.UP,
	"down": Vector2.DOWN,
	"left": Vector2.LEFT,
	"right": Vector2.RIGHT
}

func _ready() -> void:
	Game.player = self

func _physics_process(_t:float) -> void:
	
	var directions := ["up", "down", "left", "right"]
	
	for dir in directions:
		if Input.is_action_just_pressed(dir):
			if not dir_array.has(dir):
				dir_array.append(dir)
		if not is_moving and not Input.is_action_pressed(dir):
			var i = dir_array.find(dir)
			if i > -1: dir_array.remove(i)
	
	if not is_moving:
		var move_dir := Vector2.ZERO
		
		if icelocked != Vector2.ZERO:
			move_dir = icelocked
		elif dir_array.size() > 0:
			move_dir = text2vec[(dir_array[dir_array.size()-1])]
		
		if move_dir != Vector2.ZERO:
			var space_state = get_world_2d().direct_space_state
			var ray_end = position + (move_dir * Game.TILE_SIZE)
			var result = space_state.intersect_ray(position, ray_end, [self])
		
			if result.empty():
				move(move_dir)
			else:
				icelocked = Vector2.ZERO
	
	if is_moving: 
		var start:Vector2 = (last_pos*Game.TILE_SIZE) + Vector2(Game.TILE_SIZE/2.0, Game.TILE_SIZE/2.0)
		var end:Vector2 = (move_target*Game.TILE_SIZE) + Vector2(Game.TILE_SIZE/2.0, Game.TILE_SIZE/2.0)
		
		interpolation_count += 1
		position = start.linear_interpolate(end, float(interpolation_count) / float(interpolation_total))
		
		if interpolation_count == 6:
			grid_pos = move_target
			var move_dir = move_target - last_pos
			Game.map.overlay.update = true
		
		if interpolation_count == interpolation_total:
			interpolation_count = 0
			is_moving = false

func move(dir:Vector2) -> void:
	interpolation_count = 0
	is_moving = true
	steps += 1
	move_target = grid_pos + dir
	if Game.map.get_cellv(move_target) == Game.map.ICE:
		icelocked = dir
	else:
		icelocked = Vector2.ZERO
	last_pos = grid_pos
