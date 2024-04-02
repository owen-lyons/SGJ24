extends KinematicBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const Interactable = preload("Interactable.gd")

export var move_speed = 4
export var max_boat_steer_speed = 8
export var boat_steer_acceleration = 0.1

var current_interaction = null
var current_interaction_type = Interactable.EType.NONE
var anim_cache
var move_dir
var stick_input
var anim = "walk s"

onready var sprite = find_node("Sprite", true, true)
onready var boat_mesh = get_parent().find_node("Mesh")
onready var debug_text = get_parent().get_parent().get_node("UI/DebugText")
onready var interatable_area = find_node("InteractableArea")
onready var steering_meter = get_parent().get_parent().get_node("UI/SteeringMeterContainer/SteeringMeterBackground")
onready var steering_cursor = get_parent().get_parent().get_node("UI/SteeringMeterContainer/SteeringMeterBackground/SteeringCursorOffset/SteeringMeterCursor")

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
				anim = "steer"
					
				
		if (current_interaction != null):
			global_transform.origin = current_interaction.interaction_point.global_transform.origin 
	elif move_dir == Vector3.ZERO and sprite.animation == "steer":
		anim = anim_cache
		current_interaction = null
		
		
	steering_meter.visible = false
	if (current_interaction != null):
		match current_interaction_type:
			Interactable.EType.STEER:
				_handle_steering(delta)
			Interactable.EType.CANNON:
				pass
	pass

func _handle_steering(delta):
	steering_meter.visible = true
	steering_meter.position = get_viewport().get_camera().unproject_position(current_interaction.global_transform.origin)
	steering_meter.position += Vector2.UP * 32*2
	
	boat_mesh.get_parent().get_parent().steering_velocity += boat_steer_acceleration * stick_input.dot(boat_mesh.get_global_transform_interpolated().basis.x)
	
	if (abs(boat_mesh.get_parent().get_parent().steering_velocity) > max_boat_steer_speed):
		boat_mesh.get_parent().get_parent().steering_velocity = max_boat_steer_speed * sign(boat_mesh.get_parent().get_parent().steering_velocity)

	steering_cursor.position.x = 32 + -28*boat_mesh.get_parent().get_parent().steering_velocity/max_boat_steer_speed
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


