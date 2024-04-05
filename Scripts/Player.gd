extends KinematicBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const Interactable = preload("Interactable.gd")

export var move_speed = 4.0
export var max_boat_steer_speed = 8.0
export var boat_steer_acceleration = 0.1
export var cannon_duration = 3.0
export var cannon_endlag = 0.8

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
var anchor_stick_cache
var anchor_subframe = 0.0
var anchor_fill = 0.0
var anchored = false
var timer = 0.0 
var game_started = false
var anchor_speed_multiplier = 1
var capsizing = false
var dying = false
var death_time = 4

var splash_vfx = preload("../Scenes/Splash.tscn")

onready var sprite = find_node("Sprite", true, true)
onready var click_player = find_node("ClickPlayer", true, true)
onready var bonk_player = find_node("BonkPlayer", true, true)
onready var hearts_display = get_tree().root.find_node("HeartsContainer", true, false)
onready var music_player = get_tree().root.find_node("MusicPlayer", true, false)
onready var accept_player = get_tree().root.find_node("AcceptPlayer", true, false)
onready var boat_mesh = get_tree().root.find_node("BoatMesh", true, false)
onready var debug_text =  get_tree().root.find_node("DebugText", true, false)
onready var interatable_area = find_node("InteractableArea", true, false)
onready var camera =  get_tree().root.find_node("Camera", true, false)
onready var balance_meter = get_tree().root.find_node("BalanceMeterContainer", true, false)
onready var steering_meter = get_tree().root.find_node("SteeringMeterBackground", true, false)
onready var steering_cursor = get_tree().root.find_node("SteeringMeterCursor", true, false)
onready var cannon_meter = get_tree().root.find_node("CannonMeterBackground", true, false)
onready var cannon_cursor = get_tree().root.find_node("CannonMeterCursor", true, false)
onready var cannon_rect = get_tree().root.find_node("CannonMeterRect", true, false)
onready var anchor_meter = get_tree().root.find_node("AnchorMeterBackground", true, false)
onready var anchor_cursor = get_tree().root.find_node("AnchorMeterCursor", true, false)
onready var anchor_cursor2 = get_tree().root.find_node("AnchorMeterCursor2", true, false)
onready var anchor_rect = get_tree().root.find_node("AnchorFillRect", true, false)
onready var title = get_tree().root.find_node("Title", true, false)
onready var press_any = get_tree().root.find_node("PressAny", true, false)
onready var wave_spawner = get_tree().root.find_node("WaveSpawner", true, false)

func _ready():
	wave_spawner.active = false
	title.visible = true
	press_any.visible = true
	sprite.playing = false
	capsizing = false
	dying = false
	pass 

func _process(delta):
	
	if (game_started):
		if (timer > 2.0):
			if (music_player.unit_db > -5):
				music_player.unit_db -= 10 * delta
		
		
		if (title.offset.y > -128):
			title.offset.y -= 192 * delta
		else:
			title.offset.y = -128
		
		if (balance_meter.rect_position.y > 1048):
			balance_meter.rect_position.y -= 192 * delta
		else:
			balance_meter.rect_position.y = 1048
			
		if (hearts_display.rect_position.y < 0):
			hearts_display.rect_position.y += 192 * delta
		else:
			hearts_display.rect_position.y = 0
		
		_get_input(delta)
		_calculate_movement(delta)
		_handle_interactions(delta)
		_process_movement(delta)
		_update_animation(delta)
		
		
		
		if (capsizing):
			anchor_speed_multiplier = 0
			if (global_translation.y < 1.5 and not dying):
				
				var splash_node = splash_vfx.instance()
				get_tree().root.add_child(splash_node)
				splash_node.global_transform.origin = global_transform.origin + Vector3.UP * 0.2
				splash_node.rotation = Vector3.ZERO
				var newparent = get_parent().get_parent().get_parent()
				dying = true
				timer = 0
		else:
			if (anchored):
				if (anchor_speed_multiplier > 0.33):
					anchor_speed_multiplier -= 0.66 * 0.66 * delta
				else:
					anchor_speed_multiplier = 0.33
			else:
				if (anchor_speed_multiplier < 1.0):
					anchor_speed_multiplier += 0.66 * 0.66 * delta
				else:
					anchor_speed_multiplier = 1
					
		if (dying):
			global_transform.origin.y = 1.5
			global_rotation = Vector3(0,0,0)
			if (timer > death_time and sprite.frame == 6):
				visible = false
	else:
		press_any.visible = fmod(timer, 1.0) > 0.5
		
		if (Input.is_action_just_pressed("ui_accept")):
			game_started = true
			title.visible = true
			press_any.visible = false
			wave_spawner.active = true
			accept_player.playing = true
			
	timer += delta
	pass
	
func _get_input(delta):
	stick_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	stick_input = Vector3(stick_input.x, 0, stick_input.y)
	pass

func _calculate_movement(delta):
	move_dir = Vector3.ZERO;
	if current_interaction == null:
		if (stick_input.length() > 0.4):
			move_dir = stick_input
			move_dir *= 2;
	if (dying):
		move_dir *= 0.5
	pass

func _handle_interactions(delta):
	var possible_interactions = interatable_area.get_overlapping_areas()
	if (Input.is_action_pressed("ui_accept") and not capsizing):
		if (current_interaction == null):
			if (possible_interactions.size() > 0):
				current_interaction = possible_interactions[0]
				move_dir = Vector3.ZERO
				anim_cache = sprite.animation 
				current_interaction_type = current_interaction.type
				_begin_interaction(delta)
				
		if (current_interaction != null):
			global_transform.origin = current_interaction.interaction_point.global_transform.origin 
	elif move_dir == Vector3.ZERO and current_interaction != null:
		if (current_interaction_type != Interactable.EType.CANNON):
			_end_interaction(delta)
		
		
	steering_meter.visible = false
	cannon_meter.visible = false
	anchor_meter.visible = false
	if (current_interaction != null):
		match current_interaction_type:
			Interactable.EType.STEER:
				_handle_steering(delta)
			Interactable.EType.CANNON:
				_handle_cannon(delta)
			Interactable.EType.ANCHOR:
				_handle_anchor(delta)
				pass
	pass

func _begin_interaction(delta):
	anim = "steer"
	match (current_interaction_type):
		Interactable.EType.CANNON:
			sprite.frame = 0
			cannon_timer = 0
			cannon_duration = rand_range(0.8,2.0)
			cannon_target = round(rand_range(24, 56))
			cannon_cursor.position.x = cannon_target
			cannon_target += 4
			cannon_released = false
			cannon_rect.color = Color("20c028")
			cannon_success = false
		Interactable.EType.ANCHOR:
			anchor_stick_cache = Vector3(0,0,-1)
			var rope = current_interaction.find_node("Rope")

func _end_interaction(delta):
	anim = anim_cache
	current_interaction = null
	current_interaction_type = Interactable.EType.NONE

func _handle_steering(delta):
	steering_meter.visible = true
	steering_meter.position = get_viewport().get_camera().unproject_position(current_interaction.global_transform.origin)
	steering_meter.position += Vector2.UP * 32*2

	var steer_value = stick_input.dot(boat_mesh.get_global_transform_interpolated().basis.x)
	
	if (abs(steer_value) > 0.2 and fmod(timer, 0.1) < 0.03):
		if (not click_player.playing):
			click_player.playing = true
	
	current_interaction.find_node("Wheel").rotation.z -= steer_value * 5 * delta
	
	
	if (anchored):	
		boat_mesh.get_parent().get_parent().steering_velocity += boat_steer_acceleration * steer_value * 0.06
	else:
		boat_mesh.get_parent().get_parent().steering_velocity += boat_steer_acceleration * steer_value
	
	if (abs(boat_mesh.get_parent().get_parent().steering_velocity) > max_boat_steer_speed):
		boat_mesh.get_parent().get_parent().steering_velocity = max_boat_steer_speed * sign(boat_mesh.get_parent().get_parent().steering_velocity)

	if (not anchored):
		steering_cursor.position.x = 32 + -28*boat_mesh.get_parent().get_parent().steering_velocity/max_boat_steer_speed
	else:
		steering_cursor.position.x = 32 + -28*boat_mesh.get_parent().get_parent().steering_velocity/(max_boat_steer_speed * 0.04)
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
		bonk_player.playing = true
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
		if (fmod(timer, 0.1) < 0.03):
			if (not click_player.playing):
				click_player.playing = true
		
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

func _handle_anchor(delta):
	anchor_meter.visible = true
	anchor_meter.position = get_viewport().get_camera().unproject_position(current_interaction.global_transform.origin)
	anchor_meter.position += Vector2.UP * 32*2
	anchor_rect.rect_size.x = 4 + anchor_fill
	anchor_cursor2.position = 4 * Vector2(stick_input.x, stick_input.z)
	
	if (anchor_stick_cache != null):
		anchor_cursor.position = 10 * Vector2(anchor_stick_cache.x, anchor_stick_cache.z)
	else:
		anchor_cursor.position = Vector2.ZERO
	
	if (Input.is_action_just_released("scroll_down")):
		stick_input = anchor_stick_cache.rotated(Vector3.UP, PI/4)
	elif (Input.is_action_just_released("scroll_up")):
		stick_input = anchor_stick_cache.rotated(Vector3.UP, -PI/4)
	
	var rope = current_interaction.find_node("Rope")
	var anchor = current_interaction.find_node("Anchor")
	
	anchor.translation.y = -0.25 - anchor_fill/5
	
	if (stick_input.length() > 0.8):
		if (anchor_stick_cache == null):
			anchor_stick_cache = stick_input.normalized()
		else:
			var dot = stick_input.normalized().dot(anchor_stick_cache)
			
			if (dot > 0.7 and dot < 0.98):
				
				if (anchor_stick_cache.x * stick_input.z - anchor_stick_cache.z * stick_input.x > 0):
					anchor_stick_cache = stick_input.normalized()
					
					if (anchor_fill < 25):
						anchor_subframe += 0.333
						anchor_subframe = fmod(anchor_subframe, 4.0)
						rope.frame = anchor_subframe
						anchor_fill += 25 * delta
						anchor_rect.modulate = Color("20c028")
						if (not click_player.playing):
							click_player.playing = true
					elif not anchored:
						camera.shake_duration = 0.1
						camera.shake_intensity = 60
						anchor_fill = 25
						anchored = true
						bonk_player.playing = true
				else: 
					anchor_stick_cache = stick_input.normalized()
					anchor_rect.modulate = Color("20c028")
					if (anchor_fill > 0):
						anchor_subframe -= 0.333
						if (anchor_subframe < 0):
							anchor_subframe += 4
						rope.frame = anchor_subframe
						anchor_fill -= 25 * delta
						if (not click_player.playing):
							click_player.playing = true
					else:
						if (anchored):
							bonk_player.playing = true
						anchored = false
						anchor_fill = 0
					
	if anchored:
		if (fmod(timer, 0.4) < 0.2):
			anchor_rect.modulate = Color.white
		else:
			anchor_rect.modulate = Color("20c028")
	else:
		anchor_rect.modulate = Color("20c028")
		
	pass
	
func _update_animation(delta):
	
	if (dying):
		anim = "dying"
		sprite.playing = true
	else:
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
			if (current_interaction == null):
				sprite.frame = 0
			else:
				match current_interaction_type:
					Interactable.EType.ANCHOR:
						sprite.frame = 1
					Interactable.EType.CANNON:
						sprite.frame = 0
					Interactable.EType.STEER:
						sprite.frame = 0
	sprite.animation = anim;
	pass

func _process_movement(delta):
	if (not is_on_floor() and not dying):
		move_and_slide(Vector3.DOWN * 4, Vector3.UP, true)
	move_and_slide_with_snap(move_dir.normalized() * move_speed, boat_mesh.transform.basis.y * -0.25, Vector3.UP,true)
	pass


