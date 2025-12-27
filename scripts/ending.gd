extends Control

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var subtitles: Label = $subtitlesBox/Subtitles

func _ready() -> void:
	get_tree().paused = false
	Sound.playMusic("end")
	anim.play("ending")
	await anim.animation_finished
	get_tree().change_scene_to_file("res://scenes/level_select.tscn")

func set_subtitles(text: String) -> void:
	subtitles.text = tr(text)

func clear_subtitles() -> void:
	subtitles.text = ""
	
func _unhandled_input(event: InputEvent) -> void:
	#Salta l'animació
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
		skip()

func skip() -> void:
	get_tree().change_scene_to_file("res://scenes/level_select.tscn")

func translation_story() -> void:
	tr("The Prism has been restored.")
	tr("Balance has returned.")
	tr("Color has flown back into the world!")
	tr("And so, the world is whole once again.")
