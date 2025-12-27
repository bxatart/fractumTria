extends Area2D

@onready var button_anim: AnimatedSprite2D = $buttonAnim
@onready var trigger: Area2D = $Trigger
@onready var heart_icon: TextureRect = $heartIcon

@export var player_path: NodePath
@export var heal_amount: int = 1
@export var heart_full: Texture2D
@export var heart_empty: Texture2D

var player: Node = null
var active = true
var sfx_player: AudioStreamPlayer = null
var player_inside: bool = false
var needs_exit: bool = false
var timer: float = 30.0

#Estat
enum State { active, cooldown }
var current_state: State = State.active

func _ready() -> void:
	heart_icon.texture = heart_full
	player = get_node_or_null(player_path)
	if player == null:
		print("HEART SWITCH: No s'ha assignat el jugador")
	get_animation()

func get_animation() -> void:
	if current_state == State.active:
		heart_icon.texture = heart_full
		button_anim.play("ready")
	else:
		heart_icon.texture = heart_empty
		button_anim.play("cooldown")

func reset_button() -> void:
	active = true
	heart_icon.texture = heart_full
	current_state = State.active
	get_animation()

func _on_trigger_body_entered(body: Node2D) -> void:
	print("SWITCH: body_entered: ", body.name)
	if body.is_in_group("player"):
		player_inside = true
	#Surt si no es pot activar
	if not active:
		return
	#Surt si no hi ha entrat el jugador
	if not body.is_in_group("player"):
		return
	#Cura el jugador
	active = false
	needs_exit = true
	current_state = State.cooldown
	get_animation()
	#Efecte de so
	sfx_player = Sound.playSfx("checkpoint")
	player.heal(heal_amount)
	await get_tree().create_timer(timer).timeout
	reset_button()

func _on_trigger_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = false
		needs_exit = false
