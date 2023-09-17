class_name GrazingState
extends GoatState


signal finished_eating


@onready var eating_timer = $EatingTimer as Timer


func enter() -> void:
	eating_timer.start()
	animated_sprite.play("graze" + goat.get_direction_suffix())


func _on_eating_timer_timeout() -> void:
	GrassFindManager.eat_grass(goat)
	animated_sprite.play_backwards("lookup" + goat.get_direction_suffix())
	await get_tree().create_timer(1.0).timeout
	finished_eating.emit()
