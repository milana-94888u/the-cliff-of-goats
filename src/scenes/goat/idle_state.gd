extends GoatState


class LineAndDistance extends Object:
	var line: Line2D
	var distance: float


func find_closest_line(from: Vector2) -> LineAndDistance:
	# some logic
	var result := LineAndDistance.new()
	# assign found values
	return result


func enter() -> void:
	goat.velocity = Vector2.RIGHT * 40
	animated_sprite.play("graze" + goat.get_direction_suffix())


func physics_update(delta: float) -> void:
	goat.move_and_slide()
