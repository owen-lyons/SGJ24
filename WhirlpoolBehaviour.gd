extends Area


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
enum EAxis {X, Z}

export var axis_dir = EAxis.X
export var speed = 2
var boat
var splash_vfx = preload("Splash.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	boat =  get_tree().root.get_child(0).find_node("Boat", false, false)
	
	connect("body_entered", self, "_on_Whirlpool_body_entered")
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if axis_dir == EAxis.X:
		translation += transform.basis.x * speed * delta
	elif axis_dir == EAxis.Z:
		translation += transform.basis.z * speed * delta
		
		
	pass

func _on_Whirlpool_body_entered(body):
	if body.get_parent() == boat:
		boat.rotational_velocity -= speed * 0.004
		var splash_node = splash_vfx.instance()
		get_parent().add_child(splash_node)
		splash_node.translation = translation
		queue_free()
	pass # Replace with function body.
