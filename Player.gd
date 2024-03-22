extends KinematicBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var move_speed = 4

onready var sprite = find_node("Sprite", true, true)
onready var boat_mesh = get_parent().find_node("Mesh")
onready var debug_text = get_parent().get_parent().get_node("Control/RichTextLabel")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	move_and_slide(-boat_mesh.transform.basis.y * 4, boat_mesh.transform.basis.y, true)
		
		
	var moving = false;
	
	var move_dir = Vector3.ZERO;
	
	if Input.is_action_pressed("ui_down"):
		move_dir += Vector3.BACK
	
	if Input.is_action_pressed("ui_up"):
		move_dir += Vector3.FORWARD
	
	if Input.is_action_pressed("ui_left"):
		move_dir += Vector3.LEFT
	
	if Input.is_action_pressed("ui_right"):
		move_dir += Vector3.RIGHT
	
	if move_dir.length() > 0:
		
		var anim = sprite.animation;
		
		if (move_dir.x <= -1):
			anim = "walk e"
		elif (move_dir.x >= 1):
			anim = "walk w"
		
		if (move_dir.z >= 1):
			anim = "walk s"
		elif (move_dir.z <= -1):
			anim = "walk n"
		
		sprite.animation = anim;
		
		sprite.playing = true;
		
		move_and_slide(move_dir.normalized() * move_speed,boat_mesh.transform.basis.y,true,10,PI,true)
		
	else:
		#move_and_slide(Vector3.ZERO, true)
		sprite.playing = false;
		sprite.frame = 0;
	
	#debug_text.text = str(boat_mesh.transform.basis.y)
	
	pass
