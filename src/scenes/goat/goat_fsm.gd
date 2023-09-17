extends FiniteStateMachine


@export var goat: Goat


@onready var grazing_state := $GrazingState as GrazingState
@onready var lookup_state := $LookupState as LookupState
@onready var run_state := $RunState as RunState
@onready var jump_state := $JumpState as JumpState


func _on_grazing_state_finished_eating() -> void:
	transition_to(lookup_state)


func _on_lookup_state_grass_found() -> void:
	transition_to(grazing_state)
	

func proceed_path() -> void:
	var movement := goat.current_path.get_current_movement()
	if movement == null:
		transition_to(lookup_state)
		return
	if movement is Goat.GoatRun:
		transition_to(run_state)
		return
	if movement is Goat.GoatJump:
		transition_to(jump_state)
		return


func _on_lookup_state_path_found() -> void:
	proceed_path()


func _on_run_state_movement_finished() -> void:
	goat.current_path.index += 1
	proceed_path()


func _on_jump_state_movement_finished() -> void:
	goat.current_path.index += 1
	proceed_path()
