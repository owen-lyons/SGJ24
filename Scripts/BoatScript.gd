extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var time_active = 0;
# Called when the node enters the scene tree for the first time.

onready var body = get_node("BoatBody")
onready var player = body.get_node("Player")
onready var debug_text = get_parent().get_node("UI/DebugText")
onready var balance_meter = get_parent().get_node("UI/BalanceMeterContainer/BalanceMeterRect")
onready var camera = get_parent().get_node("CameraHolder/Camera")


var rotation_cap = PI/14;
var rotational_velocity = 0;
var steering_velocity = 0;

func _ready():
	time_active = 0;
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time_active += delta;
	
	var base_rotation =  0#(sin(time_active * 1.5)) * max(time_active, 1)
	

	var player_position2D = player.translation * Vector3(1,0,1)
	var local_right = -body.transform.basis.x
	var dot = local_right.dot(player_position2D)
	
	body.translation.x += delta * steering_velocity
	steering_velocity *= 0.99
	rotational_velocity -= steering_velocity * delta * delta * 0.04
	
	rotational_velocity += (dot + base_rotation) * delta * delta * 0.05
	
	body.rotation.z = body.rotation.z + rotational_velocity
	
	body.rotation.z *= 0.96
	
	if (body.rotation.z > rotation_cap or body.rotation.z < -rotation_cap):
		rotational_velocity = 0
		time_active = 0
		camera.shake_duration = 0.7
		camera.shake_intensity = 40
	
	
	
	body.rotation.z = clamp(body.rotation.z, -rotation_cap, rotation_cap)
	
	if player.anchored:
		body.rotation.z *= 0.9
		rotational_velocity *= 0.9
	
	balance_meter.rect_size.x = (60 + 60 * body.rotation.z / (rotation_cap))
	translation.y = sin(time_active * 1.5) * 0.2 - 0.2
	
	if (body.translation.x > 20):
		body.translation.x = 20
		steering_velocity *= 0.95
	if (body.translation.x < -20):
		body.translation.x = -20
		steering_velocity *= 0.95
	pass
