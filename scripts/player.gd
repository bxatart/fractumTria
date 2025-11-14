extends CharacterBody2D

@export var speed: float = 200.0 #velocitat
@export var jump: float = 300.0 #força de salt
@export var gravity: float = 400.0 #gravetat

#Colors
var colors: Array[StringName] = ["green", "orange", "purple"]
var color_index: int = 0

#Variables per l'inclinació de l'animació
var tilt_angle: float = 10.0
var tilt_speed: float = 10.0

#PROVA - Posició inicial
var spawn_position: Vector2

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var cam: Camera2D = $Camera2D
@onready var platforms:= $"../TileMapLayer"

#Estat del jugador
enum State { idle, run }
var current_state: State

func _ready():
	current_state = State.idle
	#Comença amb el color verd
	GameState.set_color(colors[color_index])
	#PROVA - Guarda la posició inicial
	spawn_position = global_position

#Moviment jugador
func _physics_process(delta):
	#Controla el canvi de color
	color_change()
	#Mira si el jugador està a l'aire
	player_falling(delta)
	#Comprovar estat del jugador
	player_idle(delta)
	player_run(delta)
	#Mou
	move_and_slide()
	#Comprova colors jugador i plataforma
	check_floor_color()
	#Canvia animació segons l'estat
	get_anim(delta)

#Gestiona el canvi de color
func color_change():
	if Input.is_action_just_pressed("swap_color"):
		#Cicle dels colors
		color_index = (color_index + 1) % colors.size()
		var new_color: StringName = colors[color_index]
		GameState.set_color(new_color)
		print("Color actual: ", new_color)

func player_falling(delta):
	#Cau si el personatge està a l'aire
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = max(velocity.y, 0.0)
	#PROVA - Si el personatge ha caigut, el torna a la posició inicial
	if global_position.y > 800:
		respawn()

func player_idle(delta):
	if is_on_floor():
		current_state = State.idle
		print("State: ", State.keys()[current_state])

func player_run(delta):
	#Moviment lateral
	var dir := Input.get_axis("move_left", "move_right")
	if dir:
		velocity.x = dir * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	if dir != 0:
		current_state = State.run
		print("State: ", State.keys()[current_state])
	#Salt
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = -jump

func get_anim(delta):
	#Color actual
	var color: StringName = GameState.current_color
	match current_state:
		State.idle:
			#Atura l'animació si el jugador no es mou
			anim.play("idle_%s" % color)
		State.run:
			#Animació de moviment
			anim.play("idle_%s" % color)
	#Dona la volta a l'sprite si el jugador va cap a l'esquerra
	anim.flip_h = velocity.x < 0
	#Rota l'sprite
	var target_tilt := 0.0
	target_tilt = deg_to_rad(tilt_angle) * sign(velocity.x)
	#Rotació suau
	var t: float = clamp(delta * tilt_speed, 0.0, 1.0)
	anim.rotation = lerp_angle(anim.rotation, target_tilt, t)

#Color del terra
func get_platform_color():
	#Mirar el 2 píxels sota el jugador
	var local_pos = platforms.to_local(global_position + Vector2(0,2))
	#Coordenades del TileMapLayer
	var coord = platforms.local_to_map(local_pos)
	#Dades de la tile
	var tile_data = platforms.get_cell_tile_data(coord)
	if tile_data:
		#Retorna el color de la plataforma
		return tile_data.get_custom_data("color")
	return null

#Comprova si el color del jugador és el mateix que el de la plataforma
func check_floor_color():
	#Si el jugador no està a la plataforma
	if not is_on_floor():
		return
	#Si el jugador està a la plataforma
	var platform_color = get_platform_color()
	#Si no hi ha plataforma a sota
	if platform_color == null:
		return
	#Si el color de la plataforma és diferent del del jugador
	if platform_color != GameState.current_color:
		#CODI PERQUÈ EL JUGADOR NO DETECTI PLATAFORMA
		print("Color diferent!")
#PROVA - Torna a la posició inicial si el jugador cau
func respawn():
	global_position = spawn_position
	velocity = Vector2.ZERO
	GameState.set_color(colors[0])
