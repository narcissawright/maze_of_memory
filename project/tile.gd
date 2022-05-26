extends Sprite

var visib = false
var solid = false
var last_seen = -1

func set_visibility(v:bool, steps:int) -> void:
	visib = v
	$overlay.visible = !v
	if v:
		last_seen = steps
	
	var opacity:float
	if last_seen > -1:
		opacity = clamp(steps - last_seen, 0.0, 100.0) / 100.0
	else:
		opacity = 1.0
	
	if opacity < 0.3 and opacity > 0.0: opacity = 0.3
	elif opacity < 0.5 and opacity > 0.3: opacity = 0.5
	elif opacity < 0.75 and opacity > 0.5: opacity = 0.75
	elif opacity > 0.75: opacity = 1.0
	
	$overlay.modulate = Color(1,1,1,opacity)
