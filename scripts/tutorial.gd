extends Area2D

@export var message: String

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		get_tree().call_group("game_ui", "show_tutorial", message)

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		get_tree().call_group("game_ui", "hide_tutorial")
