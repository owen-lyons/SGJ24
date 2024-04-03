extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var sprite = $AnimatedSprite3D
# Called when the node enters the scene tree for the first time.
func _ready():
	sprite.frame = 0
	sprite.playing = true
	pass # Replace with function body.




func _on_AnimatedSprite3D_animation_finished():
	queue_free()
	pass # Replace with function body.
