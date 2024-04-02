extends Area


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
enum EAxis {X, Z}

export var axis_dir = EAxis.X
export var speed = 2.0
onready var camera = get_parent().get_parent().get_node("CameraHolder/Camera")
var force
var boat
var splash_vfx = preload("../Scenes/Splash.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	boat =  get_tree().root.get_child(0).find_node("Boat", false, false)
	
	connect("body_entered", self, "_on_Whirlpool_body_entered")
	
	
	force = speed * scale.x * scale.x
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
		if (axis_dir == EAxis.X):
			boat.rotational_velocity -= force * 0.004
		else:
			if (global_translation.x > boat.global_translation.x):
				boat.rotational_velocity += abs(force) * 0.004
			else:
				boat.rotational_velocity -= abs(force) * 0.004
		var splash_node = splash_vfx.instance()
		get_parent().add_child(splash_node)
		splash_node.translation = translation
		camera.shake_intensity = 20 * force
		camera.shake_duration = 0.4
		queue_free()
	pass # Replace with function body.
