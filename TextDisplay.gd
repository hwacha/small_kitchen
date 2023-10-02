extends RichTextLabel

@onready var main = get_tree().get_root().get_child(0)

enum DisplayType {
	MONEY
}

@export var type : DisplayType

func _ready():
	pass

func _physics_process(_delta):
	if type == DisplayType.MONEY:
		text = "$" + str(main.money)
