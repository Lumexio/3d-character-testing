extends Spatial
class_name MannequinyMeele

# Keep same enum as original so states work
enum States { IDLE, RUN, AIR, LAND }

onready var animation_tree: AnimationTree = $AnimationTree
onready var _playback: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]

var move_direction := Vector3.ZERO setget set_move_direction
var is_moving := false setget set_is_moving

func _ready() -> void:
	animation_tree.active = true
	# Start in idle
	_playback.travel("idle")


func set_move_direction(direction: Vector3) -> void:
	move_direction = direction

	# Speed 0..1, used to blend walk/run inside move_ground
	var speed := direction.length()
	if speed > 1.0:
		speed = 1.0

	animation_tree["parameters/move_ground/blend_position"] = speed


func set_is_moving(value: bool) -> void:
	is_moving = value
	# This is what the original project uses to transition idle <-> move
	animation_tree["parameters/conditions/is_moving"] = value


func transition_to(state_id: int) -> void:
	match state_id:
		States.IDLE:
			_playback.travel("idle")
		States.LAND:
			# No land animation: just go back to idle
			_playback.travel("idle")
		States.RUN:
			_playback.travel("move_ground")
		States.AIR:
			_playback.travel("jump")
		_:
			_playback.travel("idle")
