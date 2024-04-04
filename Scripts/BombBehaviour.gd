extends Area


export var speed = 14.0
export var dir = Vector3(1,0,0)

var fall_speed = 0
var splash_vfx = preload("../Scenes/Splash.tscn")
var explosion_vfx = preload("../Scenes/Explosion.tscn")
onready var camera# = find_node("Camera",true, false)
var splashed = false
func _ready():
	camera = get_tree().root.find_node("Camera",true, false)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	translation += dir * speed * delta
	fall_speed += 0.03 * delta
	translation += Vector3.DOWN * fall_speed
	speed -= 10 * delta
	
	if (global_transform.origin.y < 1.4):
		speed *= 0.8
		if (not splashed):
			splashed = true
			var splash_node = splash_vfx.instance()
			get_tree().root.add_child(splash_node)
			splash_node.global_transform.origin = global_transform.origin + Vector3.UP * 0.2
			splash_node.rotation = Vector3.ZERO
	if (global_transform.origin.y < 0.8):
		queue_free()
	pass
	
func _on_Bomb_body_entered(body):
	var explosion_node = explosion_vfx.instance()
	get_parent().get_parent().add_child(explosion_node)
	explosion_node.global_transform.origin = global_transform.origin
	body._sink()
	camera.shake_intensity = 40
	camera.shake_duration = 0.5
	queue_free()
	pass
