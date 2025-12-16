class_name LevelRock
extends Node2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var anchor: Marker2D = $anchor

@export var level_index: int = 0
@export var texture_grey: Texture2D
@export var texture_completed: Texture2D
@export var texture_unlocked: Texture2D
@export var level_scene: PackedScene


#Estat de la roca
enum State { blocked, avaliable, completed }
var state = State.blocked

func _ready() -> void:
	if texture_grey == null:
		texture_grey = sprite.texture
	apply_texture()

#Canvia el color de la roca segons l'estat
func apply_texture() -> void:
	match state:
		State.blocked:
			sprite.texture = texture_grey
		State.avaliable:
			sprite.texture = texture_unlocked
		State.completed:
			if texture_completed != null:
				sprite.texture = texture_completed
			else:
				sprite.texture = texture_grey

func set_state(new_state = State) -> void:
	if state == new_state:
		return
	state = new_state
	apply_texture()

func is_blocked() -> bool:
	return state == State.blocked

func is_available() -> bool:
	return state == State.avaliable

func is_completed() -> bool:
	return state == State.completed

func get_anchor() -> Vector2:
	return anchor.global_position
