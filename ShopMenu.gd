extends ColorRect

var active = false : set = set_active
var menu_index = 0 : set = set_menu_index
var selection_index = 0 : set = set_selection_index

@onready var main = get_node("/root/Main")

@onready var items : VBoxContainer = $VBoxContainer
@onready var shop_window_left_ray = get_parent().get_node("LeftRay")
@onready var shop_window_right_ray = get_parent().get_node("RightRay")
@onready var shop_window_inside_left_ray = get_parent().get_node("InsideLeftRay")
@onready var shop_window_inside_right_ray = get_parent().get_node("InsideRightRay")
@onready var shop_window_left_diff = get_parent().get_node("LeftDiff")
@onready var shop_window_right_diff = get_parent().get_node("RightDiff")

var menu_items = []

var frames_down = 0 # number of frames menu up is held
var frames_up = 0 # number of frames menu down is held

var items_sold = [
	"Carrot",
	"Tomato",
	"Lettuce",
	"Bread",
	"Salt",
	"Milk",
	"Sugar",
	"Book",
	"Countertop",
	"Oven",
	"Freezer",
	"Bed",
]

func set_active(new_active):
	active = new_active
	visible = active
	
func set_menu_index(new_menu_index):
	for child in items.get_children():
		items.remove_child(child)

	for i in range(new_menu_index, new_menu_index + 5):
		items.add_child(menu_items[i])
	
	menu_index = new_menu_index

func set_selection_index(new_selection_index):
	items.get_child(selection_index - menu_index).selected = false
	if new_selection_index >= menu_index + 5:
		menu_index = new_selection_index - 4
	
	if new_selection_index < menu_index:
		menu_index = new_selection_index
	items.get_child(new_selection_index - menu_index).selected = true
	selection_index = new_selection_index

func get_input():
	if Input.is_action_pressed("menu_down") and Input.is_action_pressed("menu_up"):
		frames_down = 0
		frames_up = 0
	else:
		if Input.is_action_pressed("menu_down"):
			frames_down += 1
			if frames_down == 1 or (frames_down > 15 and frames_down % 5 == 1):
				if selection_index < items_sold.size() - 1:
					selection_index += 1
		else:
			frames_down = 0
	
		if Input.is_action_pressed("menu_up"):
			frames_up += 1
			if frames_up == 1 or (frames_up > 15 and frames_up % 5 == 1):
				if selection_index > 0:
					selection_index -= 1
		else:
			frames_up = 0
	
	if Input.is_action_just_pressed("menu_back"):
		active = false
	elif Input.is_action_just_pressed("menu_confirm"):
		var new_item_name = menu_items[selection_index].get_node("Name").text
		var new_item_cost = main.base_prices_by_item[new_item_name]
		
		if new_item_cost <= main.money:
			var new_item_path = "res://furniture/" + new_item_name + ".tscn"
			var new_item = load(new_item_path).instantiate()
			
			var price_diff = shop_window_left_diff
			
			if new_item.width == 1:
				if shop_window_right_ray.is_colliding() and shop_window_right_ray.get_collider() is Player:
					new_item.position = get_parent().position + Vector2(16, 0)
					price_diff = shop_window_right_diff
				else:
					new_item.position = get_parent().position - Vector2(16, 0)
			else:
				if shop_window_inside_left_ray.is_colliding() or shop_window_inside_right_ray.is_colliding():
					new_item.queue_free()
					return
				else:
					new_item.position = get_parent().position
			
			if new_item.height == 2:
				new_item.position.y -= 32
				
			get_node("../../Furniture").add_child(new_item)
			call_deferred("set_active", false)
			
			main.money -= new_item_cost
			
			var diff_text = preload("res://DiffText.tscn").instantiate()
			diff_text.diff = -new_item_cost
			price_diff.add_child(diff_text)

func _ready():
	var menu_item_scene = preload("res://MenuItem.tscn")
	var counter = 0
	for i in items_sold:
		var menu_item = menu_item_scene.instantiate()
		menu_item.get_node("Name").text = i
		menu_item.get_node("Price").text = "[right]$" + str(main.base_prices_by_item[i]) + "[/right]"
		menu_items.push_back(menu_item)
		if counter < 5:
			items.add_child(menu_item)
		counter += 1
		
	selection_index = 0

func _physics_process(_delta):
	if active:
		get_input()
		$UpArrow.visible = menu_index > 0
		$DownArrow.visible = menu_index + 5 < menu_items.size()
