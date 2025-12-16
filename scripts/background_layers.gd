class_name BackgroundLayer
extends Sprite2D

@export var level_index: int = 0 #Amb quin nivell es desbloqueja
@export var locked_texture: Texture2D
@export var unlocked_texture: Texture2D

func set_unlocked(unlocked: bool) -> void:
	if unlocked and unlocked_texture != null:
		texture = unlocked_texture
	elif locked_texture != null:
		texture = locked_texture
