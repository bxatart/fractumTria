extends Control

@onready var anim: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	get_tree().paused = false
	Sound.playMusic("end")
	anim.play("ending")
	await anim.animation_finished
	get_tree().change_scene_to_file("res://scenes/ending.tscn")
