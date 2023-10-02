extends Node2D

const base_prices_by_item = {
	"Carrot": 5,
	"Tomato": 4,
	"Lettuce": 1,
	"Salad": 50,
#	"Bread": 3,
#	"Milk": 2,
#	"Egg": 2,
#	"Tomato": 5,
#	"Pizza": 20,
	"Microwave": 100,
	"Bed": 120,
	"Countertop": 150
}

const BASE_TIME_RATE : float = 0.1

const BASE_MONEY       : int = 500
const BASE_HUNGER      : int = 200
const BASE_STAMINA     : float = 200
const BASE_CONTENTMENT : int = 200

const RENT_TIME : float = 24
const BASE_RENT : int   = 500

var time : float = 0
var rent : int   = BASE_RENT

var max_hunger      : int = BASE_HUNGER
var max_stamina     : float = BASE_STAMINA
var max_contentment : int = BASE_CONTENTMENT

var time_contentment_last_replenished : float = 0

var money       : int = BASE_MONEY
var hunger      : int = BASE_HUNGER : set = set_hunger
var stamina     : float = BASE_STAMINA : set = set_stamina
var contentment : int = BASE_CONTENTMENT : set = set_contentment

var speed_multiplier : float = 1 : get = get_speed_multiplier

var sleeping : bool = false : set = set_sleeping

var suppress_diff_text = false

func set_hunger(new_hunger):
	if not suppress_diff_text:
		var diff = new_hunger - hunger
		var diff_text = preload("res://DiffText.tscn").instantiate()
		diff_text.type = DiffText.DisplayType.HUNGER
		diff_text.diff = diff
		$Player/Diffs/HungerDiff.add_child(diff_text)
	
	hunger = min(new_hunger, max_hunger)
	
func set_stamina(new_stamina):
	if not suppress_diff_text:
		var diff = new_stamina - stamina
		var diff_text = preload("res://DiffText.tscn").instantiate()
		diff_text.type = DiffText.DisplayType.STAMINA
		diff_text.diff = diff
		$Player/Diffs/StaminaDiff.add_child(diff_text)

	stamina = min(new_stamina, max_stamina)
	
func set_contentment(new_contentment):
	if not suppress_diff_text:
		var diff = new_contentment - contentment
		var diff_text = preload("res://DiffText.tscn").instantiate()
		diff_text.type = DiffText.DisplayType.CONTENTMENT
		diff_text.diff = diff
		$Player/Diffs/ContentmentDiff.add_child(diff_text)

	contentment = min(new_contentment, max_contentment)

func set_sleeping(new_sleeping):
	if new_sleeping:
		$Timer.wait_time = 0.2
	else:
		$Timer.wait_time = 1
	sleeping = new_sleeping

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
	suppress_diff_text = true
	if not sleeping:
		hunger -= 1
		contentment -= max(int((time_contentment_last_replenished / 2) - 8), 0)
		time_contentment_last_replenished += BASE_TIME_RATE
	
	suppress_diff_text = false
	
	time += BASE_TIME_RATE
	
	var rent_loss = false
	
	if time >= RENT_TIME:
		var diff_text = preload("res://DiffText.tscn").instantiate()
		diff_text.position.y = 8
		diff_text.diff = -rent
		$Money.add_child(diff_text)
		money -= rent
		if money < 0:
			rent_loss = true
		rent += 100
		time = 0
	
	var hunger_loss = hunger <= 0
	var contentment_loss = contentment <= 0
	
	if rent_loss or hunger_loss or contentment_loss:
		var game_over_screen = preload("res://game_over_screen.tscn").instantiate()

		if hunger_loss:
			game_over_screen.get_node("Loss").text =\
			"You were too hungry.\nStarving artists can still starve!"
		elif rent_loss:
			game_over_screen.get_node("Loss").text =\
			"You couldn't pay the rent.\nIt's a wonder anyone can."
		elif contentment_loss:
			game_over_screen.get_node("Loss").text =\
			"You were too unhappy.\nYou've decided to move to the\ngreener pastures of Portland, OR."

		get_tree().root.add_child(game_over_screen)
		queue_free()
