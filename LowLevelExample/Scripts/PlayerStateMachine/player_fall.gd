extends State
class_name PlayerFall

@export var anim : AnimationPlayer

func enter(_prevState):
	anim.play("PeakOfJump")

func update(_delta : float):
	var p : Player = parent as Player
	
	p.align()
	
	if p.is_on_floor():
		transitioned.emit(self, "Idle")
