extends Node2D

const base_prices_by_item = {
	"Carrot": 5,
	"Tomato": 4,
	"Lettuce": 1,
	"Salad": 25,
#	"Bread": 3,
#	"Milk": 2,
#	"Egg": 2,
#	"Tomato": 5,
#	"Pizza": 20,
	"Microwave": 100,
	"Bed": 120,
	"Countertop": 150
}

const BASE_MONEY       : int = 500
const BASE_HUNGER      : int = 200
const BASE_STAMINA     : float = 200
const BASE_CONTENTMENT : int = 200

var max_hunger      : int = BASE_HUNGER
var max_stamina     : float = BASE_STAMINA
var max_contentment : int = BASE_CONTENTMENT

var money       : int = BASE_MONEY
var hunger      : int = BASE_HUNGER : set = set_hunger
var stamina     : float = BASE_STAMINA : set = set_stamina
var contentment : int = BASE_CONTENTMENT : set = set_contentment

var speed_multiplier : float = 1 : get = get_speed_multiplier

func set_hunger(new_hunger):
	hunger = min(new_hunger, max_hunger)
	
func set_stamina(new_stamina):
	stamina = min(new_stamina, max_stamina)
	
func set_contentment(new_contentment):
	contentment = min(new_contentment, max_contentment)

func get_speed_multiplier():
	var min_ratio = 1.0/18.0
	var ratio = (stamina / max_stamina)
	
	if ratio >= 1:
		return 1
	
	if ratio < min_ratio:
		return min_ratio
	else:
		return 1 / (floor(1 / ratio))

func _ready():
	$Timer.start()

#func _physics_process(delta):
#	pass

func _on_timer_timeout():
	hunger -= 1
