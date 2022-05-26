extends Control

var points = []
var lines = []

func _draw() -> void:
	for l in lines:
		draw_line(l[0], l[1], Color(0.3,0.3,0.4,1))
	for p in points:
		draw_circle (p.coord, 2.0, p.color) 
