extends Control

var points = []

func _draw() -> void:
	for p in points:
		draw_circle (p, 2.0, Color(0.3,0.8,1.0,1)) 
