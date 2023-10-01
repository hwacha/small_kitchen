extends RichTextLabel

@onready var main = get_tree().get_root().get_child(0)

func _ready():
	pass

func _physics_process(_delta):
	text = "$" + str(main.money)
