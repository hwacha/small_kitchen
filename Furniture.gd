extends StaticBody2D
class_name Furniture

const TILE_SIZE = 32
const BASE_MOVEMENT_SPEED = TILE_SIZE * 6

@export var weight : float = 1

var target
var velocity = Vector2(0, 0)

func _ready():
	target = position
	pass

func _physics_process(delta):
	velocity = Vector2(0, 0)
	if not target.is_equal_approx(position):
		velocity = position.direction_to(target) * BASE_MOVEMENT_SPEED
	move_and_collide(velocity * delta)
