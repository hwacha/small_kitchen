extends Furniture
class_name Combiner

@export var recipes : Array[Array]

var completed_recipe = null
var cooking = false

func try_add_ingredient(ingredient : Furniture) -> bool:
	var already_existing_ingredients = $Elements/Inner.get_children()
	var already_existing_this_ingredient = \
		already_existing_ingredients.filter(func (furn): return furn.kind == ingredient.kind)
	
	var viable_recipes = recipes.filter(func (recipe):
		for already_existing_ingredient in $Elements/Inner.get_children():
			print(already_existing_ingredient)
			if not already_existing_ingredient.kind in recipe[0]:
				return false
		return true)

	for recipe in viable_recipes:
		for part in recipe[0].keys():
			if ingredient.kind == part and \
				already_existing_this_ingredient.size() < recipe[0][part]:

				# get off field
				ingredient.get_parent().remove_child(ingredient)
				ingredient.get_node("Body").disabled = true
				
				# disable collision
				var rays = ingredient.get_node("Rays")
				ingredient.remove_child(rays)
				rays.queue_free()
				
			
				
				$Elements/Inner.add_child(ingredient)
				var num_ingredients = $Elements/Inner.get_child_count()
				$Elements.size.x = 32 * num_ingredients
				$Elements.position.x = -8 * num_ingredients
				$Elements/Inner.position.x = 2
				$Elements/Inner.size.x = 32 * num_ingredients - 4
				$Elements/ProgressBar.size.x = 32 * num_ingredients

				ingredient.position = Vector2(32 * (num_ingredients - 1) + 14, 14)
				ingredient.target = ingredient.position
				
				completed_recipe = get_completed_recipe()
				
				return true
	return false

func get_completed_recipe():
	var bag = {}
	for ingredient in $Elements/Inner.get_children():
		if ingredient.kind in bag.keys():
			bag[ingredient.kind] += 1
		else:
			bag[ingredient.kind] = 1
 
	for recipe in recipes:
		if bag.size() != recipe[0].size():
			continue
		var mismatch = false
		for ingr in bag:
			if not ingr in recipe[0] or bag[ingr] < recipe[0][ingr]:
				mismatch = true
				break
		if not mismatch:
			return recipe
		
	return null                                                                                                

func start_cooking():
	if not cooking:
		$CookTimer.wait_time = completed_recipe[2]
		$CookTimer.start()
		$Elements/ProgressBar.visible = true
		cooking = true

func _physics_process(_delta):
	super._physics_process(_delta)
	$Elements.visible = $Elements/Inner.get_child_count() > 0
	if not $CookTimer.is_stopped():
		$Elements/ProgressBar.value = 1 - ($CookTimer.time_left / $CookTimer.wait_time)


func _on_cook_timer_timeout():
	cooking = false
	var product = load("res://furniture/" + completed_recipe[1] + ".tscn").instantiate()
	get_parent().add_child(product)
	for spawn_point in $SpawnPoints.get_children():
		product.position = position + spawn_point.position
		break
	
	for ingr in $Elements/Inner.get_children():
		$Elements/Inner.remove_child(ingr)
		ingr.queue_free()
	
	$Elements/ProgressBar.value = 0
	$Elements/ProgressBar.visible = false
	product.target = product.position
