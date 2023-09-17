class_name FiniteStateMachine
extends Node

@export var initial_state: State

var current_state: State


func _ready() -> void:
	await get_tree().root.ready
	if initial_state:
		transition_to(initial_state)


func transition_to(target: State) -> void:
	if current_state:
		current_state.exit()
	current_state = target
	current_state.enter()


func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)


func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)
