extends Control

func _ready():
	pass


func _physics_process(_delta):
	if Input.is_action_just_pressed("menu_confirm"):
		queue_free()
		get_tree().change_scene_to_file("res://main.tscn")
	elif Input.is_action_just_pressed("menu_back"):
		pass
