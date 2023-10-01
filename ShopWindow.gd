extends StaticBody2D
class_name ShopWindow

func _physics_process(_delta):
	var left_is_furniture = ($LeftRay.is_colliding() and \
		$LeftRay.get_collider() is Furniture) or \
		$InsideLeftRay.is_colliding()
	
	var right_is_furniture = $RightRay.is_colliding() and \
		$RightRay.get_collider() is Furniture or \
		$InsideRightRay.is_colliding()
	if left_is_furniture and right_is_furniture:
		$AnimatedSprite2D.animation = "full_open"
	elif left_is_furniture:
		$AnimatedSprite2D.animation = "left_open"
	elif right_is_furniture:
		$AnimatedSprite2D.animation = "right_open"
	else:
		$AnimatedSprite2D.animation = "closed"
		
	
