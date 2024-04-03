extends RigidBody

var sinking = false

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var init_y = 0
var timer = 0
var speed = 2
# Called when the node enters the scene tree for the first time.
func _ready():
	init_y = global_transform.origin.y
	timer = 0
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	timer += delta
	if (not sinking):
		transform.origin += Vector3.FORWARD * speed * delta
		global_transform.origin.y = init_y + 0.5 * sin(timer)
	else:
		translation -= (Vector3.FORWARD * speed/3 * delta)
		global_transform.origin += (Vector3.DOWN * 1 * delta)
	
	
	pass

func _sink():
	sinking = true
	pass
