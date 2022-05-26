extends Label

func _process(delta):
	text = str(Engine.get_frames_per_second())
	text += '\n'
	text += str(Game.player.grid_pos)
