extends ColorRect

var active = false : set = set_active
var menu_index = 0 : set = set_menu_index
var selection_index = 0 : set = set_selection_index

@onready var main = get_tree().get_root().get_child(0)

@onready var items : VBoxContainer = $VBoxContainer
@onready var shop_window_left_ray = get_parent().get_node("LeftRay")
@onready var shop_window_right_ray = get_parent().get_node("RightRay")
@onready var shop_window_inside_left_ray = get_parent().get_node("InsideLeftRay")
@onready var shop_window_inside_right_ray = get_parent().get_node("InsideRightRay")

var menu_items = []

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
	if Input.is_action_just_pressed("menu_back"):
		active = false
	elif Input.is_action_just_pressed("menu_down"):
		if selection_index < main.base_prices_by_item.size() - 1:
			selection_index += 1
	elif Input.is_action_just_pressed("menu_up"):
		if selection_index > 0:
			selection_index -= 1
	elif Input.is_action_just_pressed("menu_confirm"):
		var new_item_name = menu_items[selection_index].get_node("Name").text
		var new_item_cost = main.base_prices_by_item[new_item_name]
		
		if new_item_cost <= main.money:
			var new_item_path = "res://furniture/" + new_item_name + ".tscn"
			var new_item = load(new_item_path).instantiate()
			
			if new_item.width == 1:
				if shop_window_right_ray.is_colliding() and shop_window_right_ray.get_collider() is Player:
					new_item.position = get_parent().position + Vector2(16, 0)
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

func _ready():
	var menu_item_scene = preload("res://MenuItem.tscn")
	var counter = 0
	for i in main.base_prices_by_item:
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
