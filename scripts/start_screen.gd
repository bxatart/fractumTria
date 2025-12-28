extends Control

@onready var play_button: Button = $playButton
@onready var credits: Control = $credits
@onready var credits_button: TextureButton = $creditsButton

func _ready() -> void:
	Sound.playMusic("intro")
	#Color inicial
	play_button.modulate = Color(1, 1, 1, 1)
	credits_button.modulate = Color(1, 1, 1, 0.7)
	#Modificar el color segons el focus
	credits_button.focus_entered.connect(func():
		credits_button.modulate = Color(1, 1, 1, 1)
	)
	credits_button.focus_exited.connect(func():
		credits_button.modulate = Color(1, 1, 1, 0.7)
	)
	play_button.grab_focus()
	credits.visible = false

func start_game() -> void:
	Sound.stopMusic()
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://scenes/load_game_screen.tscn")

func _on_credits_button_pressed() -> void:
	#Fer visible la pantalla de crèdits
	Sound.playSfx("menuConfirm")
	credits.visible = not credits.visible
	if credits.visible:
		credits_button.grab_focus()
	else:
		play_button.grab_focus()

func _on_play_button_pressed() -> void:
	start_game()
