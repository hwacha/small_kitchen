extends Node2D

var t : float = 0

func _draw():
	draw_circle(Vector2(0, 0), 3, Color.PLUM)
	draw_arc(Vector2(0, 0), 4, PI/2, PI/2 + (2 * PI * t), 50, Color.CORNSILK)

func _ready():
	pass

func _process(_delta):
	if t > 1:
		t = 0
	else:
		t += _delta
