extends RichTextLabel

@onready var main = get_node("/root/Main")

enum DisplayType {
	MONEY,
	RENT
}

@export var type : DisplayType

func _ready():
	pass

func _physics_process(_delta):
	if type == DisplayType.MONEY:
		if main.money < 0:
			text = "-$" + str(abs(main.money))
		else:
			text = "$" + str(main.money)
	elif type == DisplayType.RENT:
		var time_until_rent = ceil(main.RENT_TIME - main.time)
		var hours = " hour" if time_until_rent == 1 else " hours"
		text = "$" + str(main.rent) + " rent in " + str(time_until_rent) + hours
