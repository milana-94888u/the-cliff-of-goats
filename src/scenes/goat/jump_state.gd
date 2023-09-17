class_name JumpState
extends GoatState


signal movement_finished


func enter() -> void:
	goat.set_direction_by_current_movement()
	animated_sprite.play("jump_start" + goat.get_direction_suffix())


func physics_update(delta: float) -> void:
	if goat.current_path.get_current_movement().has_next_point():
		var shift := goat.current_path.get_current_movement().get_next_shift(delta)
		if animated_sprite.animation.begins_with("jump_start") and shift.y > 0:
			animated_sprite.play("jump_end" + goat.get_direction_suffix())
		goat.position += shift
	else:
		movement_finished.emit()
