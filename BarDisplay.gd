extends ProgressBar

@onready var main = get_node("/root/Main")

enum DisplayType {
	HUNGER,
	STAMINA,
	CONTENTMENT
}

@export var type : DisplayType

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if type == DisplayType.HUNGER:
		max_value = main.max_hunger
		value = main.hunger
	elif type == DisplayType.STAMINA:
		max_value = main.max_stamina
		value = main.stamina
	elif type == DisplayType.CONTENTMENT:
		max_value = main.max_contentment
		value = main.contentment
