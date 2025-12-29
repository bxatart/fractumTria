extends Control

@onready var continue_button: Button = $VBoxContainer/continueButton
@onready var exit_button: Button = $VBoxContainer/exitButton
@onready var new_game_button: Button = $VBoxContainer/newGameButton

func _ready() -> void:
	continue_button.visible = false
	if SaveGame.has_save():
		continue_button.visible = true
		continue_button.grab_focus()
	else:
		new_game_button.grab_focus()

func _on_continue_button_pressed() -> void:
	Sound.playSfx("menuConfirm")
	GameState.load_progress()
	get_tree().change_scene_to_file("res://scenes/level_select.tscn")

func _on_continue_button_focus_entered() -> void:
	Sound.playSfx("menuSelect")

func _on_new_game_button_pressed() -> void:
	Sound.playSfx("menuConfirm")
	GameState.new_game()

func _on_new_game_button_focus_entered() -> void:
	Sound.playSfx("menuSelect")

func _on_exit_button_pressed() -> void:
	Sound.playSfx("menuBack")
	await get_tree().create_timer(0.25).timeout
	#Torna a la pantalla d'inici
	get_tree().change_scene_to_file("res://scenes/start_screen.tscn")

func _on_exit_button_focus_entered() -> void:
	Sound.playSfx("menuSelect")
