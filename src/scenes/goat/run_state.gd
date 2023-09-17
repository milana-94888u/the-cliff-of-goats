class_name RunState
extends GoatState


signal movement_finished


func enter() -> void:
	goat.set_direction_by_current_movement()
	animated_sprite.play("run" + goat.get_direction_suffix())


func physics_update(delta: float) -> void:
	if goat.current_path.get_current_movement().has_next_point():
		goat.position += goat.current_path.get_current_movement().get_next_shift(delta)
	else:
		movement_finished.emit()
