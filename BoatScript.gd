extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var time_active = 0;
# Called when the node enters the scene tree for the first time.
func _ready():
	time_active = 0;
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time_active += delta;
	rotation.z = sin(time_active/2)/8
	pass
