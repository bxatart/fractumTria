extends Node2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func play_death(color: int) -> void:
	var color_name: String = GameState.get_color_name(color)
	anim.play("death_%s" % color_name)

func _on_finish_trigger_body_entered(body: Node2D) -> void:
	print("ENEMY DEATH: body_entered: ", body.name)
	if not body.is_in_group("player"):
		return
	if body.is_in_group("player"):
		get_tree().call_group("baseLevel", "trigger_game_ending")
