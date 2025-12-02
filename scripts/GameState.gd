extends Node

#Colors globals del joc
enum color { GREEN, ORANGE, PURPLE }

const color_name := {
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
	
