class_name LookupState
extends GoatState


signal grass_found
signal path_found


func enter() -> void:
	goat.current_path = GrassFindManager.find_closest_grass_path(goat)
	if goat.current_path == null:
		walk_around()
		return
	if len(goat.current_path.movements) == 0:
		start_eating()
		return
	path_found.emit()


func walk_around() -> void:
	goat.current_path = GrassFindManager.find_random_idle_path(goat)
	path_found.emit()


func start_eating() -> void:
	animated_sprite.play("lookup" + goat.get_direction_suffix())
	await get_tree().create_timer(1.0).timeout
	grass_found.emit()
