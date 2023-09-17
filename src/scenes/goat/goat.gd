class_name Goat
extends CharacterBody2D


const SPEED := 480.0


class GoatMovement extends Object:
	var origin: Vector2
	var destination: Vector2
	var current_point: Vector2
	var elapsed_time: float
	
	func post_init() -> void:
		pass
	
	func _init(from_position: Vector2, to_position: Vector2) -> void:
		origin = from_position
		destination = to_position
		current_point = origin
		elapsed_time = 0.0
		post_init()
	
	func has_next_point() -> bool:
		return not current_point.is_equal_approx(destination)
	
	func get_next_shift(_delta: float) -> Vector2:
		return Vector2.ZERO
	
	func get_direction() -> GoatDirection:
		if is_equal_approx(origin.x, destination.x):
			if origin.y > destination.y:
				return GoatDirection.UP
			else:
				return GoatDirection.DOWN
		else:
			if origin.x > destination.x:
				return GoatDirection.LEFT
			else:
				return GoatDirection.RIGHT


class GoatRun extends GoatMovement:
	var total_time: float
	
	func post_init() -> void:
		total_time = origin.distance_to(destination) / SPEED
	
	func get_next_shift(delta: float) -> Vector2:
		elapsed_time += delta
		var next_position := origin.move_toward(destination, elapsed_time / total_time)
		var result := next_position - current_point
		current_point = next_position
		return result


class GoatJump extends GoatMovement:
	var trajectory_top: Vector2
	var up_time: float
	var fall_time: float
	
	func post_init() -> void:
		trajectory_top = Vector2(
			(origin.x + destination.x) / 2.0,
			minf(origin.y, destination.y) - absf(origin.y - destination.y) / 2.0
		)
		up_time = origin.distance_to(trajectory_top) / SPEED
		fall_time = trajectory_top.distance_to(destination) / SPEED
	
	func get_next_shift(delta: float) -> Vector2:
		elapsed_time += delta
		var is_falling := elapsed_time >= up_time
		var next_position := trajectory_top.move_toward(destination, (elapsed_time - up_time) / fall_time) if is_falling else origin.move_toward(trajectory_top, elapsed_time / up_time)
		var result := next_position - current_point
		current_point = next_position
		return result
		


class GoatPathToGrass extends Object:
	var index := 0
	var movements: Array[GoatMovement]
	
	func get_current_movement() -> GoatMovement:
		if index < len(movements):
			return movements[index]
		return null


func set_direction_by_current_movement() -> void:
	current_direction = current_path.get_current_movement().get_direction()
	


var current_path: GoatPathToGrass


enum GoatDirection {UP, RIGHT, LEFT, DOWN}


@onready var collision_shape := $CollisionShape2D as CollisionShape2D
@onready var collision_rectangle := collision_shape.shape as RectangleShape2D


var current_direction := GoatDirection.RIGHT:
	set(value):
		current_direction = value
		match current_direction:
			GoatDirection.UP:
				collision_shape.position = Vector2(2, -18)
				collision_rectangle.size = Vector2(20, 40)
			GoatDirection.RIGHT:
				collision_shape.position = Vector2(-7, -10)
				collision_rectangle.size = Vector2(40, 20)
			GoatDirection.LEFT:
				collision_shape.position = Vector2(10, -10)
				collision_rectangle.size = Vector2(40, 20)
			GoatDirection.DOWN:
				collision_shape.position = Vector2(-0.5, -25)
				collision_rectangle.size = Vector2(20, 40)


func get_direction_suffix() -> String:
	match current_direction:
		GoatDirection.UP:
			return "_up"
		GoatDirection.RIGHT:
			return "_right"
		GoatDirection.LEFT:
			return "_left"
		GoatDirection.DOWN:
			return "_down"
	return ""


func _physics_process(delta: float) -> void:
	move_and_slide()
