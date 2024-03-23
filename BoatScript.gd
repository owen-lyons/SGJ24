extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var time_active = 0;
# Called when the node enters the scene tree for the first time.

onready var mesh = get_node("Mesh")
onready var player = get_parent().get_node("Player")
onready var debug_text = get_parent().get_node("UI/DebugText")
onready var balance_meter = get_parent().get_node("UI/ReferenceRect/BalanceMeterRect")
onready var camera = get_parent().get_node("CameraHolder/Camera")


var rotation_cap = PI/14;
var rotational_velocity = 0;

func _ready():
	time_active = 0;
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	time_active += delta;
	
	var base_rotation =  0#(sin(time_active * 1.5)) * max(time_active, 1)
	

	var player_position2D = player.translation * Vector3(1,0,1)
	var local_right = -mesh.transform.basis.x
	var dot = local_right.dot(player_position2D)
	
	rotational_velocity += (dot + base_rotation) * delta * delta * delta * 4
	
	mesh.rotation.z = mesh.rotation.z + rotational_velocity
	
	mesh.rotation.z *= 0.96
	
	if (mesh.rotation.z > rotation_cap or mesh.rotation.z < -rotation_cap):
		rotational_velocity = 0
		time_active = 0
		camera.shake_duration = 0.7
	
	mesh.rotation.z = clamp(mesh.rotation.z, -rotation_cap, rotation_cap)
	balance_meter.rect_size.x = (60 + 60 * mesh.rotation.z / (rotation_cap))
	
	pass
