### Maps an Animation Player's animations into a Dictionary to send data consistantly to other clients ###

extends Node
class_name AnimationMapperComponent

@export var anim : AnimationPlayer

var animMap : Dictionary[int, String] = {}

func _ready() -> void:
	createAnimationDictionary()

func createAnimationDictionary():
	var animations := anim.get_animation_list()
	for i in range(animations.size()):
		animMap[i] = animations[i]


func updateAnimator(animIndex : int, animTimeStamp : float) -> void:
	var animName := getAnimationName(animIndex)
	if animName == "NO_ANIM":
		return
	anim.play(animName)
	anim.seek(animTimeStamp, false)




func getCurrentAnimationTimeStamp() -> float:
	return anim.current_animation_position

func getCurrentAnimationIndex() -> int:
	var index = animMap.find_key(anim.current_animation)
	if index != null:
		return index
	return -1

func getAnimationIndex(animationName : String) -> int:
	var index = animMap.find_key(animationName)
	if index != null:
		return index
	return -1

func getAnimationName(animtaionIndex : int) -> String:
	if animtaionIndex > -1 and animtaionIndex < animMap.size():
		return animMap[animtaionIndex]
	else:
		return "NO_ANIM"
