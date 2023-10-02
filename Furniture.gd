extends StaticBody2D
class_name Furniture

const TILE_SIZE = 32
const BASE_MOVEMENT_SPEED : float = TILE_SIZE * 6

@onready var main = get_node("/root/Main")

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
			var resale_value = int(0.8 * main.base_prices_by_item[kind])
			main.money += resale_value
			var diff_text = preload("res://DiffText.tscn").instantiate()
			diff_text.diff = resale_value
			
			var diff_spot = main.get_node("ShopWindow/RightDiff")
			for left_ray in $Rays/Left.get_children():
				if left_ray.is_colliding() and not left_ray.get_collider() is Furniture:
					diff_spot = main.get_node("ShopWindow/LeftDiff")
					break
			
			diff_spot.add_child(diff_text)
			queue_free()
	else:
		velocity = position.direction_to(target) * BASE_MOVEMENT_SPEED * main.speed_multiplier
	position += velocity * delta
