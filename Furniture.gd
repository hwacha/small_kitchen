extends StaticBody2D
class_name Furniture

const TILE_SIZE = 32
const BASE_MOVEMENT_SPEED : float = TILE_SIZE * 6

@onready var main = get_tree().get_root().get_child(0)

@export var kind : String

@export var weight : float = 1
@export var width : int = 1
@export var height : int = 1

var target
var velocity = Vector2(0, 0)
var destroy_on_stop = false

func _ready():
	target = position
	pass

func _physics_process(delta):
	velocity = Vector2(0, 0)
	if target.is_equal_approx(position):
		if destroy_on_stop:
			main.money += int(0.8 * main.base_prices_by_item[kind])
			queue_free()
	else:
		velocity = position.direction_to(target) * BASE_MOVEMENT_SPEED * main.speed_multiplier
	position += velocity * delta
