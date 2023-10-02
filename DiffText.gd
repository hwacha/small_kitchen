extends Control

class_name DiffText

enum DisplayType {
	MONEY,
	HUNGER,
	STAMINA,
	CONTENTMENT
}

@export var type : DisplayType

const ascend_speed = 5
var diff : int = 0 : set = set_diff

func _ready():
	$Lifetime.start()
	
func set_diff(new_diff):
	diff = new_diff
	if type == DisplayType.MONEY:
		if diff < 0:
			$RichTextLabel.text = "-$" + str(abs(diff))
			$RichTextLabel.modulate = Color.CRIMSON
		elif diff > 0:
			$RichTextLabel.text = "+$" + str(diff)
			$RichTextLabel.modulate = Color.CHARTREUSE
		else:
			$RichTextLabel.text = "$" + str(abs(diff))
	else:
		if diff > 0:
			$RichTextLabel.text = "+" + str(diff)
		elif diff < 0:
			$RichTextLabel.text = str(diff)
		else:
			$RichTextLabel.text = ""

		if type == DisplayType.HUNGER:
			$RichTextLabel.modulate = Color(0.55, 1, 0.47)
		elif type == DisplayType.STAMINA:
			$RichTextLabel.modulate = Color(1, 0.96, 0.42)
		elif type == DisplayType.CONTENTMENT:
			$RichTextLabel.modulate = Color(0.25, 0.83, 1)

func _physics_process(delta):
	position.y -= sign(diff) * ascend_speed * delta

func _on_lifetime_timeout():
	get_parent().remove_child(self)
	self.queue_free()
