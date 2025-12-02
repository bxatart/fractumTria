extends Camera2D

#Per poder seleccionar el jugador a l'inspector
@export var target: NodePath
var target_node: Node2D

func _ready() -> void:
	#Comprova que s'ha assignat una target a l'inspector
	if target != NodePath():
		target_node = get_node(target) #Guarda el jugador seleccionat
	enabled = true

func _process(delta: float) -> void:
	if target_node:
		#Segueix el jugador
		global_position = target_node.global_position
