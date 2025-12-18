extends Area2D

@onready var button_anim: AnimatedSprite2D = $buttonAnim
@onready var trigger: Area2D = $Trigger

@export var final_enemy_path: NodePath
@export var disable_time: float = 15.0

var final_enemy: Node = null
var active = true
var sfx_player: AudioStreamPlayer = null
var player_inside: bool = false
var needs_exit: bool = false

#Estat
enum State { active, cooldown }
var current_state: State = State.active

func _ready() -> void:
	final_enemy = get_node_or_null(final_enemy_path)
	if final_enemy == null:
		print("SWITCH: No s'ha assignat l'enemic")
	get_animation()

func get_animation() -> void:
	if current_state == State.active:
		button_anim.play("ready")
	else:
		button_anim.play("cooldown")

func reset_button() -> void:
	active = true
	current_state = State.active
	get_animation()

func _on_trigger_body_entered(body: Node2D) -> void:
	print("SWITCH: body_entered: ", body.name)
	if body.is_in_group("player"):
		player_inside = true
	#Surt si no es pot activar
	if not active:
		return
		#surt si no hi ha enemic assignat
	if final_enemy == null:
		return
	#Surt si l'enemic ja té l'escut desactivat
	if final_enemy.shield_active == false:
		return
	#Surt si no hi ha entrat el jugador
	if not body.is_in_group("player"):
		return
	#Desactiva l'escut
	active = false
	needs_exit = true
	current_state = State.cooldown
	get_animation()
	#Efecte de so
	sfx_player = Sound.playSfx("")
	final_enemy.disable_shield(disable_time)
	#Tarda 2 segons més a tornar a activar el botó
	await get_tree().create_timer(disable_time + 2.0).timeout
	reset_button()

func _on_trigger_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = false
		needs_exit = false
