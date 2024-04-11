extends RigidBody

var sinking = false

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var player = get_tree().root.find_node("Player", true, false)

export var move_dir = Vector3.FORWARD
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
		var velocity = move_dir * speed * delta
	#	if (velocity.z > 0):
	#		velocity.z /= player.anchor_speed_multiplier
	#	else:
	#		velocity.z *= player.anchor_speed_multiplier
		transform.origin += velocity
		global_transform.origin.y = init_y + 0.5 * sin(timer)
	else:
		global_transform.origin += (Vector3.DOWN * 2 * delta)
	
	
	pass

func _sink():
	sinking = true
	pass
