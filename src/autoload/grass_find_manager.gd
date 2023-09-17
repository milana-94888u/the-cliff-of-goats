extends Node


var world: Cliff


func register_world(cliff: Cliff) -> void:
	world = cliff


func unregister_world(cliff: Cliff) -> void:
	if world == cliff:
		world = null


func find_closest_grass_path(goat: Goat) -> Goat.GoatPathToGrass:
	return world.find_path_to_grass(goat)


func find_random_idle_path(goat: Goat) -> Goat.GoatPathToGrass:
	return world.find_random_idle_path(goat)


func eat_grass(goat: Goat) -> void:
	world.eat_grass(goat)
