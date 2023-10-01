extends CharacterBody2D
class_name Player

const TILE_SIZE = 32
const BASE_MOVEMENT_SPEED = TILE_SIZE * 6

var facing_dir = "down"
var grabbing_dir = null
var accepting_input : bool = true
var frames_idle = 0

var target

@onready var tilemap : TileMap = get_node("../TileMap")
@onready var shop_menu = get_node("../ShopWindow/ShopMenu")

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
func try_move_furniture_piece(face_ray : RayCast2D) -> bool:
	var self_object = face_ray.get_parent().get_parent().get_parent()
	if face_ray.is_colliding():
		# grabbing but walking into other furniture,
		# or walking into other furniture while not grabbing
		if (grabbing_dir != facing_dir and self_object == self) or grabbing_dir == null:
			self_object.target = self_object.position
			return false

		# pushing furniture
		var pushee = face_ray.get_collider()
		
		# walking or pushing into a wall
		if not pushee is Furniture:
			if pushee is ShopWindow and self_object is Furniture:
				self_object.destroy_on_stop = true
				self_object.target = self_object.position + index_offsets_by_direction[facing_dir] * TILE_SIZE
				return true
			else:
				self_object.target = self_object.position
				return false
			
		# box hit wall
		var facing_rays = pushee.get_node("Rays/" + facing_dir.capitalize()).get_children()
		for facing_ray in facing_rays:
			if not try_move_furniture_piece(facing_ray):
				self_object.target = self_object.position
				if pushee is Furniture:
					pushee.destroy_on_stop = false
				return false

		if self_object.target.is_equal_approx(self_object.position):
			self_object.target = self_object.position + index_offsets_by_direction[facing_dir] * TILE_SIZE

		return true
	else:
		# pull
		if self_object == self and grabbing_dir != facing_dir and grabbing_dir != null:
			var grab_ray = face_ray.get_node("../../" + grabbing_dir.capitalize()).get_child(0)
			assert(grab_ray.is_colliding())
			var pullee = grab_ray.get_collider()
			var facing_rays = pullee.get_node("Rays/" + facing_dir.capitalize()).get_children()
			for facing_ray in facing_rays:
				if not try_move_furniture_piece(facing_ray):
					self_object.target = self_object.position
					return false
		
		if self_object.target.is_equal_approx(self_object.position):
			self_object.target = self_object.position + index_offsets_by_direction[facing_dir] * TILE_SIZE
		return true

func get_input():
	var walked = false
	if grabbing_dir in ["up", "down", null]:
		if Input.is_action_pressed("move_up"):
			facing_dir = "up"
			walked = true
		elif Input.is_action_pressed("move_down"):
			facing_dir = "down"
			walked = true
	if grabbing_dir in ["left", "right", null]:
		if Input.is_action_pressed("move_left"):
			facing_dir = "left"
			walked = true
		elif Input.is_action_pressed("move_right"):
			facing_dir = "right"
			walked = true

	var face_ray : RayCast2D = get_node("Rays/" + facing_dir.capitalize()).get_child(0)
	$Arm.visible = grabbing_dir != null or face_ray.is_colliding()
	$Arm.rotation = angles_by_direction[grabbing_dir if grabbing_dir != null else facing_dir]
	$Arm/GrabIcon.animation = "open" if grabbing_dir == null else "closed"
	if face_ray.is_colliding():
		var furniture = face_ray.get_collider()
		if furniture is Furniture:
			if Input.is_action_just_pressed("grab"):
				grabbing_dir = facing_dir
		else:
			$Arm.visible = false
		
		if Input.is_action_just_pressed("use"):
			if furniture is ShopWindow:
				shop_menu.active = true
				return
			else:
				print("use furniture")
	
	if walked:
		try_move_furniture_piece(face_ray)

func _physics_process(delta):
	if shop_menu.active:
		return
		
	if Input.is_action_just_released("grab"):
		grabbing_dir = null
	
	if grabbing_dir != null:
		var grab_ray = get_node("Rays/" + grabbing_dir.capitalize()).get_child(0)
		
		if not grab_ray.is_colliding() or not grab_ray.get_collider() is Furniture:
			grabbing_dir = null

	velocity = Vector2(0, 0)
	accepting_input = self.position.is_equal_approx(target)
	if accepting_input:
		get_input()
	else:
		velocity = self.position.direction_to(target) * BASE_MOVEMENT_SPEED
		position += velocity * delta

	if velocity.is_zero_approx():
		frames_idle += 1
		frames_idle = min(frames_idle, 5)
	else:
		frames_idle = 0

	var anim_dir = grabbing_dir if grabbing_dir != null else facing_dir
	if frames_idle >= 2:
		$AnimatedSprite2D.animation = "idle_" + anim_dir
	else:
		$AnimatedSprite2D.animation = "walk_" + anim_dir
