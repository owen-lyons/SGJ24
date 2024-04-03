extends KinematicBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const Interactable = preload("Interactable.gd")

export var move_speed = 4.0
export var max_boat_steer_speed = 8.0
export var boat_steer_acceleration = 0.1
export var cannon_duration = 3.0
export var cannon_endlag = 0.5

var bomb_scene = preload("../Scenes/Bomb.tscn")
var current_interaction = null
var current_interaction_type = Interactable.EType.NONE
var anim_cache
var move_dir
var stick_input
var anim = "walk s"
var cannon_timer
var cannon_target
var cannon_time_at_released
var cannon_released
var cannon_success


onready var sprite = find_node("Sprite", true, true)
onready var boat_mesh = get_parent().find_node("Mesh")
onready var debug_text = get_parent().get_parent().get_node("UI/DebugText")
onready var interatable_area = find_node("InteractableArea")
onready var camera = get_parent().get_parent().get_node("CameraHolder/Camera")
onready var steering_meter = get_parent().get_parent().get_node("UI/SteeringMeterContainer/SteeringMeterBackground")
onready var steering_cursor = get_parent().get_parent().get_node("UI/SteeringMeterContainer/SteeringMeterBackground/SteeringCursorOffset/SteeringMeterCursor")
onready var cannon_meter = get_parent().get_parent().get_node("UI/CannonMeterContainer/CannonMeterBackground")
onready var cannon_cursor = get_parent().get_parent().get_node("UI/CannonMeterContainer/CannonMeterBackground/CannonMeterCursorOffset/CannonMeterCursor")
onready var cannon_rect = get_parent().get_parent().get_node("UI/CannonMeterContainer/CannonMeterBackground/CannonMeterRect")

func _ready():
	pass 

func _process(delta):
	_get_input(delta)
	_calculate_movement(delta)
	_handle_interactions(delta)
	_process_movement(delta)
	_update_animation(delta)
	pass
	
func _get_input(delta):
	stick_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	stick_input = Vector3(stick_input.x, 0, stick_input.y).normalized()
	pass

func _calculate_movement(delta):
	move_dir = Vector3.ZERO;
	if current_interaction == null:
		if (stick_input.length() > 0.4):
			move_dir = stick_input
			move_dir *= 2;
	pass

func _handle_interactions(delta):
	var possible_interactions = interatable_area.get_overlapping_areas()
	if (Input.is_action_pressed("ui_accept")):
		if (current_interaction == null):
			if (possible_interactions.size() > 0):
				current_interaction = possible_interactions[0]
				move_dir = Vector3.ZERO
				anim_cache = sprite.animation 
				current_interaction_type = current_interaction.type
				_begin_interaction(delta)
				anim = "steer"
		if (current_interaction != null):
			global_transform.origin = current_interaction.interaction_point.global_transform.origin 
	elif move_dir == Vector3.ZERO and current_interaction != null:
		if (current_interaction_type != Interactable.EType.CANNON):
			_end_interaction(delta)
		
		
	steering_meter.visible = false
	cannon_meter.visible = false
	if (current_interaction != null):
		match current_interaction_type:
			Interactable.EType.STEER:
				_handle_steering(delta)
			Interactable.EType.CANNON:
				_handle_cannon(delta)
				pass
	pass

func _begin_interaction(delta):
	match (current_interaction_type):
		Interactable.EType.CANNON:
			cannon_timer = 0
			cannon_duration = rand_range(0.8,2.0)
			cannon_target = round(rand_range(24, 56))
			cannon_cursor.position.x = cannon_target
			cannon_target += 4
			cannon_released = false
			cannon_rect.color = Color("20c028")
			cannon_success = false

func _end_interaction(delta):
	anim = anim_cache
	current_interaction = null
	current_interaction_type = Interactable.EType.NONE

func _handle_steering(delta):
	steering_meter.visible = true
	steering_meter.position = get_viewport().get_camera().unproject_position(current_interaction.global_transform.origin)
	steering_meter.position += Vector2.UP * 32*2
	
	boat_mesh.get_parent().get_parent().steering_velocity += boat_steer_acceleration * stick_input.dot(boat_mesh.get_global_transform_interpolated().basis.x)
	
	if (abs(boat_mesh.get_parent().get_parent().steering_velocity) > max_boat_steer_speed):
		boat_mesh.get_parent().get_parent().steering_velocity = max_boat_steer_speed * sign(boat_mesh.get_parent().get_parent().steering_velocity)

	steering_cursor.position.x = 32 + -28*boat_mesh.get_parent().get_parent().steering_velocity/max_boat_steer_speed
	pass

func _handle_cannon(delta):
	if Input.is_action_just_released("ui_accept") and not cannon_released:
		cannon_released = true
		cannon_timer = 0
		var accuracy = abs(cannon_target - ((cannon_rect.rect_size.x) * 10/3.0))
		current_interaction._spawn_cannonball()
		var new_bomb = bomb_scene.instance()
		current_interaction.add_child(new_bomb)
		new_bomb.translation = Vector3.ZERO
		if (accuracy < 6):
			camera.shake_intensity = 40
			camera.shake_duration = 0.4
			cannon_success = true
			new_bomb.speed = 25
		else:
			camera.shake_intensity = 20
			camera.shake_duration = 0.4
			new_bomb.speed = max(20 - accuracy/3, 10)
		
	
	if (cannon_released):
		if (fmod(cannon_timer, 0.2) < 0.1):
			cannon_rect.color = Color.white
		else:
			if (cannon_success):
				cannon_rect.color = Color("20c028")
			else:
				cannon_rect.color = Color.red
			
		if (cannon_timer > cannon_endlag):
			_end_interaction(delta)
			return
	else:
		var cannon_value = (abs(fmod(-((20 * cannon_timer/cannon_duration) + 20) , (2 * 20)) + 20));
		
		if abs(cannon_target - ((cannon_rect.rect_size.x) * 10/3.0)) < 4:
			cannon_rect.color = Color.white
		else:
			cannon_rect.color = Color("20c028")
			
		cannon_rect.rect_size.x = cannon_value
		
		
	cannon_meter.visible = true
	cannon_meter.position = get_viewport().get_camera().unproject_position(current_interaction.global_transform.origin)
	cannon_meter.position += Vector2.UP * 32*2
	cannon_timer += delta
	
	
	
	
	pass

func _update_animation(delta):
	if move_dir.length() > 0.5:
		if (abs(move_dir.x) > abs(move_dir.z)):
			if (move_dir.x <= -0.5):
				anim = "walk w"
			elif (move_dir.x >= 0.5):
				anim = "walk e"
		else:
			if (move_dir.z >= 0.5):
				anim = "walk s"
			elif (move_dir.z <= -0.5):
				anim = "walk n"
		sprite.playing = true;
	else:
		sprite.playing = false;
		sprite.frame = 0;
	sprite.animation = anim;
	pass

func _process_movement(delta):
	if (not is_on_floor()):
		move_and_slide(Vector3.DOWN * 4, Vector3.UP, true)
	move_and_slide_with_snap(move_dir.normalized() * move_speed, boat_mesh.transform.basis.y * -0.25, Vector3.UP,true)
	pass


