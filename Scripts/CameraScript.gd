extends Camera


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


var shake_duration
var shake_intensity = 40
var init_offset
var count 
# Called when the node enters the scene tree for the first time.
func _ready():
	count = 0
	shake_duration = 0;
	init_offset = Vector2(h_offset, v_offset)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	count += 1
	if (shake_duration > 0):
		if (count % 2 == 0):
			var random_shake = shake_intensity * delta * shake_duration
			h_offset = rand_range(-random_shake, random_shake)
			v_offset = rand_range(-random_shake, random_shake)
		shake_duration -= delta
	else:
		h_offset = lerp(h_offset,init_offset.x, 0.2)
		v_offset = lerp(v_offset,init_offset.y, 0.2)
		shake_duration = 0
	pass
