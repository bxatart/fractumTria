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

func _unhandled_input(_event):
	if Input.is_action_just_pressed("start_game") and not credits.visible:
		start_game()

func start_game() -> void:
	#PROVA - Hi ha d'anar la cutscene primer
	Sound.stopMusic()
	get_tree().change_scene_to_file("res://scenes/levels/level_1.tscn")

func _on_credits_button_pressed() -> void:
	#Fer visible la pantalla de crèdits
	credits.visible = not credits.visible
	if credits.visible:
		credits_button.grab_focus()
	else:
		play_button.grab_focus()
