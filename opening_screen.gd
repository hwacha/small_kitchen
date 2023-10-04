extends Control


func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("menu_confirm") or Input.is_action_just_pressed("menu_back"):
		get_tree().change_scene_to_file("res://main.tscn")
