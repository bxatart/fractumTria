extends Node

#Nivells
@export var total_levels: int = 4
var levels_completed = create_levels_array(total_levels)
var last_level_played: int = -1 #Cap nivell assignat
var last_entry_color: color = color.GREEN #Color a l'entrar al nivell
var has_entry_color: bool = false

#Vida
const base_health: int = 3
var player_health: int = 3
var player_max_health: int = 3

#Colors globals del joc
enum color { GREEN, ORANGE, PURPLE }

const color_name = {
	color.GREEN: "green",
	color.ORANGE: "orange",
	color.PURPLE: "purple"
}
# Color actual del jugador
var current_color: color = color.GREEN

# Senyal per indicar el canvi de color
signal color_changed(new_color: color)

# Funció per canviar de color
func set_color(new_color: color):
	if current_color == new_color:
		return
	current_color = new_color
	emit_signal("color_changed", current_color)

#Obtenir el nom del color com a StringName
func get_color_name(c: color) -> StringName:
	return color_name[c]

func create_levels_array(total_levels: int) -> Array[bool]:
	var arr: Array[bool] = []
	for i in range(total_levels):
		arr.append(false)
	return arr

func complete_level(level_index: int) -> void:
	#Sortir de la funció si l'index no és vàlid
	if level_index < 0 or level_index >= levels_completed.size():
		return
	#Marcar nivell completat
	levels_completed[level_index] = true

func is_level_completed(level_index: int) -> bool:
	#Sortir de la funció si l'index no és vàlid
	if level_index < 0 or level_index >= levels_completed.size():
		return false
	#Retorna true o false segons si s'ha completat el nivell
	return levels_completed[level_index]

func max_unlocked_index() -> int:
	var i = 0
	#Mirar quin és l'últim nivell completat
	while i < levels_completed.size() and levels_completed[i]:
		i += 1
	#Retorna el nivell que toca jugar
	return clamp(i, 0, levels_completed.size() - 1)

func set_last_level_played(level_index: int) -> void:
	last_level_played = level_index

func save_entry_color(c: color) -> void:
	last_entry_color = c
	has_entry_color = true

func restore_entry_color() -> void:
	if has_entry_color:
		set_color(last_entry_color)

func get_level_color(level_index: int) -> color:
	match level_index:
		0: 
			return color.GREEN
		1: 
			return color.ORANGE
		2: 
			return color.PURPLE
		_:
			return color.GREEN

func set_player_health(current: int, max: int) -> void:
	player_max_health = max
	player_health = clamp(current, 0, max)

func reset_player_health() -> void:
	player_max_health = base_health
	player_health = base_health

func save_progress() -> void:
	SaveGame.save_game(levels_completed, last_level_played, player_health, player_max_health, int(current_color))

func load_progress() -> void:
	var data = SaveGame.load_game()
	if data.is_empty():
		return
	#Nivell
	levels_completed = data["levels_completed"]
	last_level_played = int(data["last_level_played"])
	#Vides
	player_health = int(data["health"])
	player_max_health = int(data["max_health"])
	#Color
	set_color(color.values()[int(data["color"])])

func reset_progress() -> void:
	levels_completed = create_levels_array(total_levels)
	last_level_played = -1
	player_health = base_health
	player_max_health = base_health
	current_color = color.GREEN

func new_game() -> void:
	SaveGame.delete_save()
	reset_progress()
	get_tree().change_scene_to_file("res://scenes/intro.tscn")
