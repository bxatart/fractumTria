extends Control

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var subtitles: Label = $CanvasLayer/subtitlesBox/Subtitles

func _ready() -> void:
	Sound.playMusic("introAnim")
	anim.play("intro")

func set_subtitles(text: String) -> void:
	subtitles.text = tr(text)

func clear_subtitles() -> void:
	subtitles.text = ""

func _unhandled_input(event: InputEvent) -> void:
	#Salta la intro
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
		skip()

func skip() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/level_1.tscn")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
		get_tree().change_scene_to_file("res://scenes/levels/level_1.tscn")

func translation_story() -> void:
	tr("At the center of the world, a tower watched in silence.")
	tr("Within it, the Prism endured.")
	tr("Until something awoke.")
	tr("A corruption without color. Without purpose.")
	tr("The balance broke.")
	tr("The Prism shattered.")
	tr("And the world fractured with it.")
	tr("One fragment endured.")
	tr("Three colors answered.")
	tr("The world lost its light. The fragment did not.")
	tr("It could now shift. But it was still incomplete.")
	tr("To return to the tower, it had to endure them all.")
	tr("Green was the first.")
