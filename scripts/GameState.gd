extends Node

## Color actual del jugador
var current_color: StringName = "green"

## Senyal per indicar el canvi de color
signal color_changed(new_color: StringName)

## Funció per canviar de color
func set_color(new_color: StringName):
	if current_color == new_color:
		return
	current_color = new_color
	emit_signal("color_changed", current_color)
