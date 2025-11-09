extends State
class_name PlayerIdle

@export var anim : AnimationPlayer

func enter(_prevState : State):
	anim.play("Idle")

func update(_delta : float):
	var p : Player = parent as Player
	
	if p.jumpVelocity.y > 0 and !p.is_on_floor():
		transitioned.emit(self, "Fall")
		return
	
	if Input.is_action_just_pressed("Jump") and p.is_on_floor():
		transitioned.emit(self, "Jump")
		return
	
	if abs(p.walkVelocity.x) > 0:
		transitioned.emit(self, "Walk")
		return
