extends Area2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var trigger: Area2D = $Trigger

@export var heal_amount: int = 1

var active: bool = false
var player: CharacterBody2D = null
var sfx_player: AudioStreamPlayer = null

func _on_trigger_body_entered(body: Node2D) -> void:
	#Si ja està activat l'altar
	if active:
		return
	#Si no és el jugador
	if not body.is_in_group("player"):
		return
	player = body
	#Mirar que el jugador hi sigui a sobre
	if not player.is_on_floor():
		return
	active = true
	player.disable_control()
	sfx_player = Sound.playSfx("checkpoint")
	if player.has_method("heal"):
		player.heal(heal_amount)
	if sfx_player != null and sfx_player.playing:
		await sfx_player.finished
	if player.has_method("set_spawn_position"):
		player.set_spawn_position(player.global_position)
	sfx_player = null
	player.enable_control()
	
