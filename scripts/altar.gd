extends Area2D

@onready var anim: AnimatedSprite2D = $altarBack
@onready var trigger: Area2D = $Trigger

@export var color: GameState.color = GameState.color.GREEN

var active = false
var player: CharacterBody2D = null
var sfx_player: AudioStreamPlayer = null

#Estat
enum State { idle, fill }
var current_state: State = State.idle

func _ready() -> void:
	reset_altar()
	get_animation()

func get_animation() -> void:
	var color_name: String = GameState.get_color_name(color)
	if current_state == State.idle:
		anim.play("idle_%s" % color_name)
	elif current_state == State.fill:
		anim.play("fill_%s" % color_name)

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
	#Canvi d'animació
	current_state = State.fill
	get_animation()
	#Efecte de so
	sfx_player = Sound.playSfx("endLevel")
	if player.has_method("full_heal"):
		player.full_heal()

func _on_altar_animation_finished() -> void:
	if current_state != State.fill:
		return
	#Si no hi ha jugador
	if player == null:
		return
	if sfx_player != null and sfx_player.playing:
		await sfx_player.finished
	player.disable_control()
	if player.has_method("start_exit"):
		player.start_exit()
	sfx_player = null

func reset_altar() -> void:
	active = false
	player = null
	current_state = State.idle
	
