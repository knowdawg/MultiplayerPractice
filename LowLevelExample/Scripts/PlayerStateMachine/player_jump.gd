extends State
class_name PlayerJump

@export var anim : AnimationPlayer

func enter(_prevState):
	anim.play("StartOfJump")
	
	var p : Player = parent as Player
	p.jump()

func update(_delta : float):
	var p : Player = parent as Player
	
	p.align()
	
	if p.jumpVelocity.y > 0 and !p.is_on_floor():
		transitioned.emit(self, "Fall")
		return
	
	if p.jumpVelocity.y >= 0.0 and p.is_on_floor():
		transitioned.emit(self, "Idle")
		return
