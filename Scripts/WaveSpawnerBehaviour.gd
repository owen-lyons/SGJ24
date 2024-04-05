extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var wave_info
var spawn_array = []
var timer = 0.0
var active = false
var whirlpool_scene = preload("../Scenes/Whirlpool.tscn")
var iceberg_scene = preload("../Scenes/Iceberg.tscn")
onready var debug_text = get_parent().get_node("UI/DebugText")
# Called when the node enters the scene tree for the first time.
func _ready():
	
	spawn_array.clear()
	add_whirlpool(1, Vector3(20,0,0), Vector3(-1,0,0))
	add_whirlpool(3, Vector3(-20,0,0), Vector3(1,0,0))
	add_whirlpool(5, Vector3(2,0,-20), Vector3(0,0,1), 2, 4)
	add_whirlpool(7, Vector3(15,0,20), Vector3(-1,0,-1))
	add_iceberg(0, Vector3(-4,0,40), Vector3(0,0,-1), 1, 1)
	add_iceberg(0, Vector3(10,0,43), Vector3(0,0,-1), 2, 0.5)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (not active):
		return
	for spawn_info in spawn_array:
		if !spawn_info.spawned and spawn_info.spawn_at_time < timer:
			spawn_info.spawned = true
			match spawn_info.hazard_type:
				SpawnInfo.EHazard.WHIRLPOOL:
					spawn_whirlpool(spawn_info)
					spawn_info = null
				SpawnInfo.EHazard.ICEBERG:
					spawn_iceberg(spawn_info)
					spawn_info = null
	#debug_text.text = str(timer)
	timer += delta
	pass

func add_whirlpool(time_to_spawn, position, move_dir = Vector3(-1,0,0), speed = 4, scale = Vector3.ONE):
	var new = SpawnInfo.new()
	new.hazard_type = SpawnInfo.EHazard.WHIRLPOOL
	new.spawn_at_time = time_to_spawn
	new.spawn_position = position
	new.move_dir = move_dir.normalized()
	new.move_speed = speed
	new.scale = Vector3.ONE * scale
	spawn_array.append(new)
	pass
	
func add_iceberg(time_to_spawn, position, move_dir = Vector3(-1,0,0), speed = 0.5, scale = Vector3.ONE):
	var new = SpawnInfo.new()
	new.hazard_type = SpawnInfo.EHazard.ICEBERG
	new.spawn_at_time = time_to_spawn
	new.spawn_position = position
	new.move_dir = move_dir.normalized()
	new.move_speed = speed
	new.scale = Vector3.ONE * scale
	spawn_array.append(new)
	pass
	
func spawn_whirlpool(spawn_info):
	var whirlpool = whirlpool_scene.instance()
	get_parent().add_child(whirlpool)
	whirlpool.translation = spawn_info.spawn_position + Vector3.UP * 1.55
	whirlpool.move_dir = spawn_info.move_dir
	whirlpool.scale = spawn_info.scale
	whirlpool.speed = spawn_info.move_speed
	whirlpool._ready()
	
func spawn_iceberg(spawn_info):
	var iceberg = iceberg_scene.instance()
	get_parent().add_child(iceberg)
	iceberg.translation = spawn_info.spawn_position
	iceberg.move_dir = spawn_info.move_dir
	iceberg.scale = spawn_info.scale
	iceberg.speed = spawn_info.move_speed
	iceberg._ready()
