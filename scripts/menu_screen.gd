extends Control

signal settings_requested

@onready var continue_button: Button = $VBoxContainer/continueButton
@onready var exit_button: Button = $VBoxContainer/exitButton

@export var pause = false
@export var level_select = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true
	if pause:
		exit_button.text = tr("EXIT TO LEVEL SELECT")
	elif level_select:
		exit_button.text = tr("EXIT TO TITLE SCREEN")
	await get_tree().process_frame
	continue_button.grab_focus()

func _on_continue_button_pressed() -> void:
	get_tree().paused = false
	Sound.playSfx("menuConfirm")
	await get_tree().create_timer(0.25).timeout
	#Tanca el menú
	queue_free()

func _on_config_button_pressed() -> void:
	Sound.playSfx("menuConfirm")
	await get_tree().create_timer(0.25).timeout
	settings_requested.emit()

func _on_exit_button_pressed() -> void:
	Sound.playSfx("menuBack")
	await get_tree().create_timer(0.25).timeout
	get_tree().paused = false
	if pause:
		GameState.restore_entry_color()
		get_tree().change_scene_to_file("res://scenes/level_select.tscn")
	elif level_select:
		#Pantalla d'inici
		get_tree().change_scene_to_file("res://scenes/start_screen.tscn")

func _on_continue_button_focus_entered() -> void:
	Sound.playSfx("menuSelect")

func _on_config_button_focus_entered() -> void:
	Sound.playSfx("menuSelect")

func _on_exit_button_focus_entered() -> void:
	Sound.playSfx("menuSelect")
