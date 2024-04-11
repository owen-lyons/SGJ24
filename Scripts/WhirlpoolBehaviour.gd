extends Area


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var move_dir = Vector3.ZERO
export var speed = 2.0
onready var camera = get_tree().root.find_node("Camera",true, false)
onready var player = get_tree().root.find_node("Player", true, false)
var force
var boat
var splash_vfx = preload("../Scenes/Splash.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	boat =  get_tree().root.get_child(0).find_node("Boat", false, false)
	
	connect("body_entered", self, "_on_Whirlpool_body_entered")
	
	
	
	force = speed * scale.x * scale.x * 0.5
	
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	var velocity = move_dir * speed * delta
	#if (player.anchored):
	#	if (velocity.z > 0):
	#		velocity.z *= (1 + player.anchor_speed_multiplier)
	#	else:
	#		velocity.z *= player.anchor_speed_multiplier
	translation += velocity
		
		
	pass

func _on_Whirlpool_body_entered(body):
	if body.get_parent() == boat:
		if (abs(move_dir.dot(Vector3(1,0,0))) > abs(move_dir.dot(Vector3(0,0,1)))):
			boat.rotational_velocity -= sign(move_dir.dot(Vector3(1,0,0))) * force * 0.004
		else:
			if (global_translation.x < boat.global_translation.x):
				boat.rotational_velocity += abs(force) * 0.004
			else:
				boat.rotational_velocity -= abs(force) * 0.004
		var splash_node = splash_vfx.instance()
		get_parent().add_child(splash_node)
		splash_node.translation = translation
		camera.shake_intensity = 20 * force
		camera.shake_duration = 0.4
		boat._splash_sfx()
		queue_free()
	pass # Replace with function body.
