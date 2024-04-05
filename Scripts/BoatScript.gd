extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var time_active = 0;
# Called when the node enters the scene tree for the first time.
var health = 5


onready var body = get_node("BoatBody")
onready var ocean_noise = body.get_node("AudioStreamPlayer3D")
onready var splash_player = body.get_node("SplashPlayer")
onready var player = body.get_node("Player")
onready var debug_text = get_parent().get_node("UI/DebugText")
onready var balance_meter = get_parent().get_node("UI/BalanceMeterContainer/BalanceMeterRect")
onready var camera = get_parent().get_node("CameraHolder/Camera")
onready var left_trails = body.get_node("LeftTrails")
onready var right_trails = body.get_node("RightTrails")
onready var hearts_display = get_tree().root.find_node("HeartsContainer", true, false)

var capsizing = false
var rotation_cap = PI/14;
var rotational_velocity = 0;
var steering_velocity = 0;
var time_at_last_health_lost = 0

func _ready():
	capsizing = false
	time_active = 0;
	pass # Replace with function body.

func _splash_sfx():
	splash_player.playing = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	for i in 5:
		if (health > i):
			hearts_display.get_child(i).get_child(0).frame = 0
		else:
			hearts_display.get_child(i).get_child(0).frame = 1
	
	
	if (player.timer < 4 + time_at_last_health_lost and health > 0 and health < 5):
		if fmod(player.timer - time_at_last_health_lost, 0.5) < 0.25:
			hearts_display.get_child(health).get_child(0).frame = 1
		else:
			hearts_display.get_child(health).get_child(0).frame = 0
	
	
	
	if (health == 0):
		_capsize()
	
	ocean_noise.unit_size = 5 + player.anchor_speed_multiplier * 10
	
	if (capsizing):
		if (body.rotation.z < PI/2):
			body.rotation.z+= delta * 0.5
		else:
			body.translation.y -= 2.5 * delta
			
		if (body.translation.y < -14):
			 get_tree().reload_current_scene()
	else:
		time_active += delta;
		
		var base_rotation =  0#(sin(time_active * 1.5)) * max(time_active, 1)
		

		var player_position2D = player.translation * Vector3(1,0,1)
		var local_right = -body.transform.basis.x
		var dot = local_right.dot(player_position2D)
		
		body.translation.x += delta * steering_velocity
		if (not player.anchored):
			steering_velocity *= 0.995
		else:
			steering_velocity *= 0.98
		rotational_velocity -= steering_velocity * delta * delta * 0.1
		
		rotational_velocity += (dot + base_rotation) * delta * delta * 0.1
		
		body.rotation.z = body.rotation.z + rotational_velocity
		
		body.rotation.z *= 0.96
		
		if (body.rotation.z > rotation_cap or body.rotation.z < -rotation_cap):
			rotational_velocity = 0
			time_active = 0
			camera.shake_duration = 0.7
			camera.shake_intensity = 40
			health -= 1
			splash_player.playing = true
			time_at_last_health_lost = player.timer

		body.rotation.z = clamp(body.rotation.z, -rotation_cap, rotation_cap)
		
		if player.anchored:
			body.rotation.z *= 0.965
			rotational_velocity *= 0.965
		
		balance_meter.rect_size.x = (60 + 60 * body.rotation.z / (rotation_cap))
		translation.y = sin(time_active * 1.5) * 0.2 - 0.2
		
		if (body.translation.x > 20):
			body.translation.x = 20
			steering_velocity *= 0.95
		if (body.translation.x < -20):
			body.translation.x = -20
			steering_velocity *= 0.95
		
	if (capsizing):
		left_trails.visible = false
		right_trails.visible = true
		right_trails.global_transform.origin =  body.global_transform.origin + Vector3(1,0,1).normalized()*0.3
		right_trails.global_transform.origin -= body.global_transform.basis.x * 3
		right_trails.translation += Vector3.FORWARD
		right_trails.global_transform.origin.y = 1.6
		right_trails.global_rotation = Vector3(-PI/6,PI/4.0,0)
		right_trails.scale.y = clamp(body.translation.y --5.5, 0,1)
	else:
		right_trails.global_transform.origin.y = min(1.8, 1.7 - 4 * body.rotation.z)
		left_trails.global_transform.origin.y = min(2, 1.7 + 4 * body.rotation.z)
		left_trails.scale.y = clamp(player.anchor_speed_multiplier * 1 * (1 - 10 * body.rotation.z), 0.01, 1.5)
		right_trails.scale.y = clamp(player.anchor_speed_multiplier * 1 * (1 + 10 * body.rotation.z), 0.01, 1.5)
	pass

func _capsize():
	if (!capsizing):
		splash_player.playing = true
		capsizing = true
		player.capsizing = true
	pass

func _on_IcebergArea_area_entered(area):
	health = 0
	pass # Replace with function body.
