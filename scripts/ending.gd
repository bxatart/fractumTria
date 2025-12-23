extends Control

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var subtitles: Label = $subtitlesBox/Subtitles

func _ready() -> void:
	get_tree().paused = false
	Sound.playMusic("end")
	anim.play("ending")
	await anim.animation_finished
	get_tree().change_scene_to_file("res://scenes/start_screen.tscn")

func set_subtitles(text: String) -> void:
	subtitles.text = tr(text)

func clear_subtitles() -> void:
	subtitles.text = ""

func translation_story() -> void:
	tr("The Prism was restored.")
	tr("Balance returned.")
	tr("Color flowed back into the world.")
	tr("The world was whole again.")
