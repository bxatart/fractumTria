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
	tr("At the top of the world, a tower watched in silence.")
	tr("Within it stood the Prism...")
	tr("... until something awoke.")
	tr("A corruption without color. Without purpose.")
	tr("It disrupted the balance,")
	tr("the Prism shattered,")
	tr("and so the world was fractured.")
	tr("But one fragment endured.")
	tr("Only three colors were saved.")
	tr("The world had lost its light, but the fragment had not.")
	tr("Though still incomplete, it could now shift.")
	tr("To return to the tower, it had to tread carefully.")
	tr("And so the first new light was green.")
