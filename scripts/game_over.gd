extends Control

@onready var retry_button: Button = $VBoxContainer/retryButton
@onready var anim_player: AnimationPlayer = $AnimationPlayer

@export var level_scene_path: String = ""

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	anim_player.process_mode = Node.PROCESS_MODE_ALWAYS
	Sound.playMusic("gameOver")
	get_tree().paused = true
	#Animació d'entrada
	anim_player.play("in")
	await anim_player.animation_finished
	await get_tree().process_frame
	retry_button.grab_focus()

func _on_retry_button_pressed() -> void:
	get_tree().paused = false
	retry_button.disabled = true
	Sound.playSfx("menuConfirm")
	await get_tree().create_timer(0.25).timeout
	GameState.reset_player_health()
	#Tornar a carregar el mateix nivell
	get_tree().change_scene_to_file(level_scene_path)

func _on_exit_button_pressed() -> void:
	get_tree().paused = false
	Sound.playSfx("menuBack")
	await get_tree().create_timer(0.25).timeout
	GameState.restore_entry_color()
	GameState.reset_player_health()
	#Carregar el level select
	get_tree().change_scene_to_file("res://scenes/level_select.tscn")

func _on_retry_button_focus_entered() -> void:
	Sound.playSfx("menuSelect")

func _on_exit_button_focus_entered() -> void:
	Sound.playSfx("menuSelect")
