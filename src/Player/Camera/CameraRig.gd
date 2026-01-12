tool
extends Spatial
class_name CameraRig
# Accessor class that gives the nodes in the scene access the player or some
# frequently used nodes in the scene itself.
# Also handles mouse-look camera control.

signal aim_fired(target_position)

# Mouse look settings
export var mouse_sensitivity := 0.1
export var min_pitch := -80.0
export var max_pitch := 80.0

onready var camera: InterpolatedCamera = $InterpolatedCamera
onready var spring_arm: SpringArm = $SpringArm
onready var aim_ray: RayCast = $InterpolatedCamera/AimRay
onready var aim_target: Sprite3D = $AimTarget

var player: KinematicBody

var zoom: = 0.5 setget set_zoom

onready var _position_start: Vector3 = translation
var _pitch := 0.0


func _ready() -> void:
	set_as_toplevel(true)
	yield(owner, "ready")
	player = owner


func _unhandled_input(event: InputEvent) -> void:
	if Engine.editor_hint:
		return
	
	# Handle mouse motion for camera rotation
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		# Yaw: rotate the rig horizontally (around Y axis)
		rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		
		# Pitch: rotate the spring_arm vertically (around local X axis)
		_pitch = clamp(_pitch - event.relative.y * mouse_sensitivity, min_pitch, max_pitch)
		spring_arm.rotation_degrees.x = _pitch


func _get_configuration_warning() -> String:
	return "Missing player node" if not player else ""


func set_zoom(value: float) -> void:
	zoom = clamp(value, 0.0, 1.0)
	spring_arm.zoom = zoom
