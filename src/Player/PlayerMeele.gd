tool
class_name PlayerMeele
extends KinematicBody
# Helper class for the Player scene's scripts to be able to have access to the
# camera and its orientation.

onready var camera: CameraRig = $CameraRig
onready var skin = $MannequinyMeele
onready var state_machine: StateMachine = $StateMachine


func _get_configuration_warning() -> String:
	return "Missing camera node" if not camera else ""
