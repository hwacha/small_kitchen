extends Furniture
class_name Food

@export var hunger      : int = 0
@export var stamina     : int = 0
@export var contentment : int = 0

const consume_speed = 5

var starting_position
var ending_position
var consumed = false
var t : float = 0

func consume(player_position):
	starting_position = position
	ending_position = player_position
	consumed = true

func _physics_process(delta):
	super._physics_process(delta)
	if consumed:
		t += consume_speed * delta
		position = lerp(starting_position, ending_position, t)
		scale = Vector2(1 - t, 1 - t)
	if t >= 1:
		queue_free()
