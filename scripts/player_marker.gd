extends Node2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var colors: Array[GameState.color] = [
	GameState.color.GREEN, 
	GameState.color.ORANGE, 
	GameState.color.PURPLE
	]
var color_index: int = 0

var last_dir: int = 1

func _ready() -> void:
	anim.visible = true
	#Canvi de color
	GameState.color_changed.connect(on_color_changed)
	#Inicialitza l'índex segons el color actual
	color_index = max(0, colors.find(GameState.current_color))
	on_color_changed(GameState.current_color)
	get_anim()

#Gestiona el canvi de color
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("swap_color"):
		change_color()
		
func change_color() -> void:
	if colors.is_empty():
		return
	color_index = (color_index + 1) % colors.size()
	GameState.set_color(colors[color_index])
	Sound.playSfx("changeColor")

func on_color_changed(new_color: GameState.color) -> void:
	#Sincronitza l'índex amb el color nou
	var idx = colors.find(new_color)
	if idx != -1:
		color_index = idx

	get_anim()
func get_anim() -> void:
	#Color actual
	var color_name: StringName = GameState.get_color_name(GameState.current_color)
	anim.play("idle_%s" % color_name)
	#Dona la volta a l'sprite si el jugador va cap a l'esquerra
	anim.flip_h = last_dir < 0

func move_direction(dir: int) -> void:
	if dir == 0:
		return
	last_dir = sign(dir)
	get_anim()
