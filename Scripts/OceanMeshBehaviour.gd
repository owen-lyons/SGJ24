extends MeshInstance


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var player = get_tree().root.find_node("Player", true, false)

export var speed = 0.2
var timer = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	timer += delta
	#get_active_material(0).get_texture(SpatialMaterial.TEXTURE_NORMAL).noise.lacunarity = 1 + 1*(abs(sin(timer * 2)))
	get_active_material(0).get_texture(SpatialMaterial.TEXTURE_NORMAL).noise.period = 40 + 10 * cos(timer)
	get_active_material(0).uv1_offset.z += delta * speed * player.anchor_speed_multiplier
	get_active_material(0).uv1_offset.z += delta * speed * player.anchor_speed_multiplier
	pass
