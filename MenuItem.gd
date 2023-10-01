extends HBoxContainer
class_name MenuItem

@export var selected = false : set = set_selected

func set_selected(new_selected: bool):
	selected = new_selected
	queue_redraw()

func _ready():
	pass # Replace with function body.

func _draw():
	if selected:
		draw_rect(Rect2(Vector2(-3, 0), Vector2(size.x + 7, 18)), Color.FLORAL_WHITE, false)
	
