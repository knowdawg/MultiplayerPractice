extends State
class_name PlayerWalk

@export var anim : AnimationPlayer

func enter(_prevState):
	anim.play("Walk")


func update(_delta : float):
	var p : Player = parent as Player
	
	p.align()
	
	if p.jumpVelocity.y > 0 and !p.is_on_floor():
		transitioned.emit(self, "Fall")
		return
	
	if Input.is_action_just_pressed("Jump") and p.is_on_floor():
		transitioned.emit(self, "Jump")
		return
	
	if abs(p.walkVelocity.x) == 0.0:
		transitioned.emit(self, "Idle")
		return
