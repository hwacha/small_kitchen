extends CharacterBody2D
class_name Player

const TILE_SIZE = 32
const BASE_MOVEMENT_SPEED : float = TILE_SIZE * 6
var USE_FOOD_DELAY_THRESHOLD : float = 0.333 # seconds

var facing_dir = "down"
var grabbing_dir = null
var accepting_input : bool = true
var frames_idle = 0

var target
var time_travelling : float = 0

var waking_destination = null
var covers = null

var first_frame = true

var use_hold_time  : float = 0
var furniture_to_be_used : Furniture = null

@onready var tilemap : TileMap = get_node("../TileMap")
@onready var shop_menu = get_node("../ShopWindow/ShopMenu")
@onready var main = get_node("/root/Main")

const index_offsets_by_direction = {
	"up": Vector2(0, -1),
	"down": Vector2(0, 1),
	"left": Vector2(-1, 0),
	"right": Vector2(1, 0),
}

const angles_by_direction = {
	"up": 0,
	"down": PI,
	"left": -PI/2,
	"right": PI/2
}

func _ready():
	target = self.position
	$AnimatedSprite2D.play()

# returns false iff there is a
# furniture piece in line which can't be moved
func try_move_furniture_piece(face_ray : RayCast2D, moved_furniture: Array[Furniture]) -> bool:
	var self_object = face_ray.get_parent().get_parent().get_parent()
	if face_ray.is_colliding():
		# grabbing but walking into other furniture,
		# or walking into other furniture while not grabbing
		if (grabbing_dir != facing_dir and self_object == self) or grabbing_dir == null:
			self_object.target = self_object.position
			return false

		# pushing furniture
		var pushee = face_ray.get_collider()
		
		# pushing into combiner
		if self_object is Furniture and pushee is Combiner:
			if pushee.try_add_ingredient(self_object):
				return true
		
		# pushing into a product
		if self_object is Furniture and not pushee is ShopWindow and pushee.get_parent() != get_node("/root/Main/Furniture"):
			self_object.target = self_object.position
			return false
		
		# walking or pushing into a wall
		if not pushee is Furniture:
			if pushee is ShopWindow and self_object is Furniture:
				if not self_object in moved_furniture:
					self_object.destroy_on_stop = true
					self_object.target = self_object.position + index_offsets_by_direction[facing_dir] * TILE_SIZE
					moved_furniture.push_front(self_object)
					return true
			else:
				if self_object in moved_furniture:
					moved_furniture.erase(self_object)
				self_object.target = self_object.position
				return false
			
		# box hit wall
		if pushee.get_node_or_null("Rays") != null:
			var facing_rays = pushee.get_node("Rays/" + facing_dir.capitalize()).get_children()
			for facing_ray in facing_rays:
				if not try_move_furniture_piece(facing_ray, moved_furniture):
					self_object.target = self_object.position
					if pushee is Furniture:
						pushee.destroy_on_stop = false
					return false

		if self_object.target.is_equal_approx(self_object.position):
			self_object.target = self_object.position + index_offsets_by_direction[facing_dir] * TILE_SIZE
		
		if self_object is Furniture and not self_object in moved_furniture:
			moved_furniture.push_front(self_object)
		return true
	else:
		# pull
		if self_object == self and grabbing_dir != facing_dir and grabbing_dir != null:
			var grab_ray = face_ray.get_node("../../" + grabbing_dir.capitalize()).get_child(0)
			assert(grab_ray.is_colliding())
			var pullee = grab_ray.get_collider()
			var facing_rays = pullee.get_node("Rays/" + facing_dir.capitalize()).get_children()
			for facing_ray in facing_rays:
				if not try_move_furniture_piece(facing_ray, moved_furniture):
					self_object.target = self_object.position
					return false
		
		if self_object.target.is_equal_approx(self_object.position):
			self_object.target = self_object.position + index_offsets_by_direction[facing_dir] * TILE_SIZE
			
		if self_object is Furniture and not self_object in moved_furniture:
			moved_furniture.push_front(self_object)
		return true

func get_input(delta):
	if waking_destination != null:
		if Input.is_action_just_pressed("use"):
			target = waking_destination
			waking_destination = null
			covers.z_index = 0
			covers = null
			main.sleeping = false
			$Arm.visible = true
			$Arm/GrabIcon.visible = false
			$Arm/UseIndicator.visible = false
		return
		
	var walked = false
	if Input.is_action_pressed("move_up"):
		facing_dir = "up"
		walked = true
	elif Input.is_action_pressed("move_down"):
		facing_dir = "down"
		walked = true
	elif Input.is_action_pressed("move_left"):
		facing_dir = "left"
		walked = true
	elif Input.is_action_pressed("move_right"):
		facing_dir = "right"
		walked = true

	var face_ray : RayCast2D = get_node("Rays/" + facing_dir.capitalize()).get_child(0)
	$Arm.rotation = angles_by_direction[grabbing_dir if grabbing_dir != null else facing_dir]
	
	$Arm/GrabIcon.visible = grabbing_dir != null or face_ray.is_colliding()
	$Arm/UseIndicator.visible = false
	$Arm/GrabIcon.animation = "open" if grabbing_dir == null else "closed"
	$Arm/UseIndicator.t = use_hold_time / USE_FOOD_DELAY_THRESHOLD
	
	if face_ray.is_colliding():
		var furniture = face_ray.get_collider()
		$Arm/UseIndicator.visible = grabbing_dir == null and \
			(furniture is Food or \
			furniture is ShopWindow or \
			(furniture is Furniture and furniture.kind == "Bed") or \
			(furniture is Combiner and \
				furniture.completed_recipe != null and \
				not furniture.cooking))
		if furniture is Furniture:
			if Input.is_action_just_pressed("grab"):
				grabbing_dir = facing_dir

		else:
			$Arm/GrabIcon.visible = grabbing_dir != null
		
		if Input.is_action_just_pressed("use") and grabbing_dir == null:
			if furniture is ShopWindow:
				shop_menu.active = true
				return

			elif furniture is Combiner:
				if furniture.completed_recipe != null:
					furniture.start_cooking()
			elif furniture is Furniture and furniture.kind == "Bed":
				waking_destination = position
				covers = furniture.get_node("Covers")
				covers.z_index = 5
				target = furniture.position + Vector2(0, 8)
				main.sleeping = true
				$Arm.visible = false
		
		if Input.is_action_pressed("use") and furniture != null and furniture is Furniture:
			if furniture != furniture_to_be_used or (furniture is Food) and furniture.consumed:
				use_hold_time = 0

			use_hold_time += delta
			furniture_to_be_used = furniture
		
		if use_hold_time >= USE_FOOD_DELAY_THRESHOLD and furniture is Food:
			use_hold_time = 0
			main.hunger      += furniture.hunger
			main.stamina     += furniture.stamina
			main.contentment += furniture.contentment
			furniture.consume(position)
	else:
		use_hold_time = 0
	
	if Input.is_action_just_released("use"):
		use_hold_time = 0
		
	if walked and waking_destination == null:
		var moved_furniture : Array[Furniture] = []
#		var should_abort_move : bool = false
		if try_move_furniture_piece(face_ray, moved_furniture):
			var sum = func(accum, furn):
				return accum + furn.weight
			var total_weight = moved_furniture.reduce(sum, 0)
			var strength = 5
	
			main.suppress_diff_text = true
			main.stamina -= total_weight / strength
			main.suppress_diff_text = false
#		else:
#			should_abort_move = true

func _physics_process(delta):
	if first_frame:
		first_frame = false
		return

	if shop_menu.active:
		return
		
	if Input.is_action_just_released("grab"):
		if grabbing_dir != null:
			facing_dir = grabbing_dir
		
		grabbing_dir = null
	
	if grabbing_dir != null:
		var grab_ray = get_node("Rays/" + grabbing_dir.capitalize()).get_child(0)
		
		if not grab_ray.is_colliding() or not grab_ray.get_collider() is Furniture:
			grabbing_dir = null
	
	var speed = BASE_MOVEMENT_SPEED * main.speed_multiplier
	if time_travelling * speed >= 32:
		position = target
	velocity = Vector2(0, 0)
	accepting_input = self.position.is_equal_approx(target)
	if accepting_input:
		time_travelling = 0
		get_input(delta)
	else:
		velocity = self.position.direction_to(target) * speed
		position += velocity * delta
		time_travelling += delta

	if velocity.is_zero_approx():
		frames_idle += 1
		frames_idle = min(frames_idle, 5)
	else:
		frames_idle = 0

	var anim_dir = "down" if waking_destination != null else \
		(grabbing_dir if grabbing_dir != null else facing_dir)
	if frames_idle >= 2:
		$AnimatedSprite2D.animation = "idle_" + anim_dir
	else:
		$AnimatedSprite2D.animation = "walk_" + anim_dir
