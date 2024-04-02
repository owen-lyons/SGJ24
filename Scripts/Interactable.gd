extends Area

enum EType{NONE,STEER,CANNON,ANCHOR}

export (EType) var type = EType.NONE

onready var interaction_point = find_node("InteractionPoint")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

