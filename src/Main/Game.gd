extends Node

# Default player scene if no choice was made in the main menu
export(PackedScene) var default_player_scene := preload("res://src/Player/Player.tscn")

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_spawn_selected_player()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if event.is_action_pressed("toggle_mouse_captured"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		get_tree().set_input_as_handled()

	if event.is_action_pressed("toggle_fullscreen"):
		OS.window_fullscreen = not OS.window_fullscreen
		get_tree().set_input_as_handled()

func _spawn_selected_player() -> void:
	# Choose player scene: Global.player_scene if set, else default
	var player_scene := Global.player_scene if Global.player_scene else default_player_scene
	
	# Reset Global.player_scene after reading it
	Global.player_scene = null
	
	# Find and remove the existing placeholder Player node
	var existing_player := get_node_or_null("Player")
	if existing_player:
		var spawn_transform := existing_player.global_transform
		existing_player.queue_free()
		
		# Instance the chosen player
		var new_player := player_scene.instance()
		new_player.name = "Player"
		new_player.global_transform = spawn_transform
		add_child(new_player)
