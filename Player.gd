extends AnimatedSprite3D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var move_speed = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	var moving = false;
	
	if Input.is_action_pressed("ui_down"):
		translation += Vector3(move_speed,0,0).rotated(Vector3.UP, TAU*135/360) * delta
		animation = "walk s"
		moving = true;
	
	if Input.is_action_pressed("ui_up"):
		translation += Vector3(-move_speed,0,0).rotated(Vector3.UP, TAU*135/360) * delta
		animation = "walk n"
		moving = true;
	
	if Input.is_action_pressed("ui_left"):
		translation += Vector3(0,0,move_speed).rotated(Vector3.UP, TAU*135/360) * delta
		animation = "walk w"
		moving = true;
	
	if Input.is_action_pressed("ui_right"):
		translation += Vector3(0,0,-move_speed).rotated(Vector3.UP, TAU*135/360) * delta
		animation = "walk e"
		moving = true;
		
	if moving:
	
		playing = true;
	else:
		playing = false;
		frame = 0;
		
	pass
