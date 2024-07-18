extends Node

@export var greatest_force: int = 150
@export var farthest_mar: int = 100

func find_force(object_pos: Vector2, ray_cast: RayCast2D) -> Vector2:
	var vec: Vector2 = Vector2.ZERO 
	var point_pos = ray_cast.get_collision_point()
	var x_val = 5000
	var y_val = 100000
	var divider: = Vector2(x_val, y_val)

	vec = divider/(object_pos - point_pos)

#postive side to clamp close x values
	if vec.x >= greatest_force:
		vec.x = greatest_force
	elif vec.x <= -greatest_force:
		vec.x = -greatest_force
#negative side to clamp close x values
	if vec.y >= greatest_force:
		vec.y = greatest_force
	elif vec.y <= -greatest_force:
		vec.y = -greatest_force

#This is to ensure that the farthest object does not experince the most amount of force
	if vec.x < farthest_mar and vec.x > -farthest_mar:
		vec = Vector2.ZERO
#		print("xes")
	if vec.y < farthest_mar and vec.y > -farthest_mar:
		vec = Vector2.ZERO
#		print("yes")

	return vec 
