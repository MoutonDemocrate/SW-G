extends Node
class_name StateMachine

var states : Array[State]
var current_state : State

signal state_changed(from : State, to : State)

func _ready() -> void :
	refetch_states()
	current_state = states[0]

func refetch_states() -> void :
	states = []
	for child in get_children() :
		if child is State :
			states.append(child)

# Changes the current state, returns old state
func change_state(new_state : State) -> State :
	var old_state : State = current_state
	current_state = new_state
	print("State changed from ",old_state.name ," to ",new_state.name)
	old_state.left(new_state)
	state_changed.emit(old_state, new_state)
	new_state.entered(old_state)
	return current_state

# Changes the current state from state namestring, returns old state
func change_state_from_name(new_state_name : String) -> State :
	var that_one_satate : State
	for state in states :
		if state.name == new_state_name :
			that_one_satate = state
	return change_state(that_one_satate)

# Changes the current state from state index, returns old state
func change_state_from_index(new_state_index : int) -> State :
	return change_state(states[new_state_index % len(states)])

func add_state(new_state : State) -> State :
	self.add_child(new_state)
	refetch_states()
	return new_state

func delete_state(state : State):
	state.queue_free()
	refetch_states()
