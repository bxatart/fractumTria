extends Node
#Ruta on es guardarà el joc
var save_path = "user://savegame.save"

#Guardar la partida
func save_game(levels_completed: Array, last_level_played: int, player_health: int, player_max_health: int, current_color: int) -> void:
	#Crea el fitxer
	var cfg = ConfigFile.new()
	cfg.set_value("progress", "levels_completed", levels_completed)
	cfg.set_value("progress", "last_level_played", last_level_played)
	cfg.set_value("player", "health", player_health)
	cfg.set_value("player", "max_health", player_max_health)
	cfg.set_value("player", "color", current_color)
	#Guarda el fitxer
	cfg.save(save_path)

func has_save() -> bool:
	#Mira si hi ha alguna partida guardada
	return FileAccess.file_exists(save_path)

func load_game() -> Dictionary:
	if not has_save():
		#Retorna diccionari buit
		return {}
	#Crea un fitxer nou
	var cfg = ConfigFile.new()
	#Si hi ha algun error al fitxer
	if cfg.load(save_path) != OK:
		return {}
	#Diccionari amb les dades guardades
	return {
		"levels_completed": cfg.get_value("progress", "levels_completed", []),
		"last_level_played": int(cfg.get_value("progress", "last_level_played", -1)),
		"health": int(cfg.get_value("player", "health", 3)),
		"max_health": int(cfg.get_value("player", "max_health", 3)),
		"color": int(cfg.get_value("player", "color", 0)),
	}
