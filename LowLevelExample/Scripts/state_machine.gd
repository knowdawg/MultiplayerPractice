extends Node
class_name StateMachine

@export var initial_state : State
@export var parent : Node

var current_state : State
var states : Dictionary = {}
signal stateSwitched(prevState : State, newState : State)

# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.transitioned.connect(onChildTransition)
			child.parent = parent
			
	if !NetworkHandler.isServer and !parent is Player: return #If you are not on the server and you are not a player, return
	if parent is Player: #If you are not your own player, return
		if parent.isAuthority == false: return
	
	if initial_state:
		initial_state.enter(null)
		current_state = initial_state
		stateSwitched.emit(null, initial_state)

func _process(delta):
	if current_state:
		current_state.update(delta)

func _physics_process(delta):
	if current_state:
		current_state.update_physics(delta)

#Called by the signal
func onChildTransition(state : State, new_state_name):
	if state != current_state:
		return
	
	switchStates(new_state_name)

#Call for manualy overwriting State
func switchStates(newState : String):
	var n = states.get(newState.to_lower())
	
	var prevState : State = null
	if current_state:
		prevState = current_state
		current_state.exit(n)
	
	if !n:
		printerr(newState + ": Non-existant State")
	else:
		n.enter(prevState)
	stateSwitched.emit(prevState, n)
	current_state = n
