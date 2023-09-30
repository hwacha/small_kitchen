extends CharacterBody2D


const BASE_MOVEMENT_SPEED = 32 * 6

var facing_dir = "down"
var grabbing_dir = null
var accepting_input : bool = true
var frames_idle = 0

var target

@onready var tilemap : TileMap = get_node("../TileMap")

const index_offsets_by_direction = {
	"up": Vector2i(0, -1),
	"down": Vector2i(0, 1),
	"left": Vector2i(-1, 0),
	"right": Vector2i(1, 0),
}

func _ready():
	target = self.position
	$AnimatedSprite2D.play()

# returns false iff there is a
# furniture piece in line which can't be moved
func try_move_furniture_piece(tilemap_index) -> bool:
	var wall_source_id = tilemap.get_cell_source_id(1, tilemap_index)
	if wall_source_id != -1:
		return false

	var furniture_source_id = tilemap.get_cell_source_id(2, tilemap_index)
	if furniture_source_id != -1:
		if grabbing_dir == null:
			return false
			
		var atlas_coords = tilemap.get_cell_atlas_coords(2, tilemap_index)
			
		if grabbing_dir != facing_dir:
			tilemap.set_cell(2, tilemap_index, -1)
			tilemap.set_cell(2, tilemap_index + index_offsets_by_direction[facing_dir], furniture_source_id, atlas_coords)
			return true

		var next_tilemap_index = tilemap_index + index_offsets_by_direction[grabbing_dir]
		if not try_move_furniture_piece(next_tilemap_index):
			return false

		tilemap.set_cell(2, tilemap_index, -1)
		tilemap.set_cell(2, next_tilemap_index, furniture_source_id, atlas_coords)

	return true

func get_input():
	var offset = Vector2(0, 0)
	if grabbing_dir in ["up", "down", null]:
		if Input.is_action_pressed("move_up"):
			facing_dir = "up"
			if not $RayUp.is_colliding():
				offset = Vector2(0, -32)
		elif Input.is_action_pressed("move_down"):
			facing_dir = "down"
			if not $RayDown.is_colliding():
				offset = Vector2(0, 32)
	if grabbing_dir in ["left", "right", null]:
		if Input.is_action_pressed("move_left"):
			facing_dir = "left"
			if not $RayLeft.is_colliding():
				offset = Vector2(-32, 0)
		elif Input.is_action_pressed("move_right"):
			facing_dir = "right"
			if not $RayRight.is_colliding():
				offset = Vector2(32, 0)
	
	var tilemap_player_index = tilemap.local_to_map(position)
	var face_index = tilemap_player_index + index_offsets_by_direction[facing_dir]
	var face_source_id = tilemap.get_cell_source_id(2, face_index)
	if Input.is_action_just_pressed("grab") and face_source_id != -1:
		grabbing_dir = facing_dir
	
	target = self.position + offset
	var grab_index = face_index
	
	if grabbing_dir != null:
		grab_index = tilemap_player_index + index_offsets_by_direction[grabbing_dir]
	
	if offset != Vector2(0, 0):
		if not try_move_furniture_piece(grab_index):
			target = self.position

func _physics_process(delta):
	if Input.is_action_just_released("grab"):
		grabbing_dir = null

	velocity = Vector2(0, 0)
	accepting_input = self.position.is_equal_approx(target)
	if accepting_input:
		get_input()
	else:
		velocity = self.position.direction_to(target) * BASE_MOVEMENT_SPEED
		move_and_collide(velocity * delta)

	if velocity.is_zero_approx():
		frames_idle += 1
		frames_idle = min(frames_idle, 5)
	else:
		frames_idle = 0

	if frames_idle >= 2:
		$AnimatedSprite2D.animation = "idle_" + facing_dir
	else:
		$AnimatedSprite2D.animation = "walk_" + facing_dir
