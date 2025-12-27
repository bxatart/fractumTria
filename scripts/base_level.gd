class_name BaseLevel
extends Node2D

@onready var game_ui: CanvasLayer = $gameUI
@onready var player: CharacterBody2D = $Player
@onready var hud: Control = $gameUI/HUD

var ending_running = false

func _ready() -> void:
	add_to_group("baseLevel")
	player.max_health = GameState.player_max_health
	player.health = clamp(GameState.player_health, 0, player.max_health)
	player.emit_signal("health_changed", player.health, player.max_health)
	print("Player HP: ", player.health, "/", player.max_health)
	#Cors inicials
	hud.setup_hearts(player.max_health)
	hud.update_hearts(player.health)
	#Guarda vides inicials
	GameState.set_player_health(player.health, player.max_health)
	#Mira si hi ha canvis i actualitza els cors
	player.health_changed.connect(func(current, max):
		GameState.set_player_health(current, max)
		if hud.max_hearts != max:
			hud.setup_hearts(max)
		hud.update_hearts(current)
	)

func _unhandled_input(event) -> void:
	if event.is_action_pressed("pause"):
		game_ui.open_pause_menu(true, false)

func show_game_over() -> void:
	var game_over = preload("res://scenes/levels/game_over.tscn").instantiate()
	game_over.level_scene_path = scene_file_path
	add_child(game_over)

func trigger_game_ending() -> void:
	if ending_running:
		return
	ending_running = true
	game_ui.hide_tutorial()
	player.disable_control()
	#Pausa el joc
	get_tree().paused = true
	game_ui.process_mode = Node.PROCESS_MODE_ALWAYS
	#Flash
	await game_ui.flash_white()
	await get_tree().create_timer(1.5).timeout
	#Canvia a escena final
	get_tree().paused = false
	GameState.reset_player_health()
	get_tree().change_scene_to_file("res://scenes/ending.tscn")
