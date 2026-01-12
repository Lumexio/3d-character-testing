extends Control

# Adjust these paths if your repo uses different ones.
const PLAYER_A_SCENE := preload("res://src/Player/Player.tscn")
const PLAYER_B_SCENE := preload("res://src/Player/PlayerMeele.tscn")
const GAME_SCENE := preload("res://src/Main/Game.tscn")

func _ready() -> void:
	$ButtonPlayerA.connect("pressed", self, "_on_ButtonPlayerA_pressed")
	$ButtonPlayerB.connect("pressed", self, "_on_ButtonPlayerB_pressed")

func _on_ButtonPlayerA_pressed() -> void:
	_start_game(PLAYER_A_SCENE)

func _on_ButtonPlayerB_pressed() -> void:
	_start_game(PLAYER_B_SCENE)

func _start_game(player_scene: PackedScene) -> void:
	# Remember the player choice globally
	Global.player_scene = player_scene
	# Switch to the Game scene; Game.gd will read Global.player_scene
	get_tree().change_scene_to(GAME_SCENE)
