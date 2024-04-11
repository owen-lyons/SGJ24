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
	# Big Whirlpool
	# add_whirlpool(0, Vector3(-40,0,1), Vector3(1,0,-0.1), 1.7, 3)

	# Wave 1 - Rolling the Woodpile Down [Tutorial] 
	add_whirlpool(5, Vector3(-30,0,1), Vector3(1,0,-0.1), 4, .7)
	add_whirlpool(10, Vector3(30,0,-3), Vector3(-1,0,0.2), 4, 1)
	add_iceberg(15, Vector3(0,0,40), Vector3(0,0,-1), 3, 1)
	add_iceberg(15, Vector3(10,0,50), Vector3(0,0,-1), 3, 0.5)
	add_whirlpool(35, Vector3(30,0,-3), Vector3(-1,0,0.2))
	add_whirlpool(35, Vector3(40,0,2), Vector3(-1,0,0.1))
	add_whirlpool(35, Vector3(-35,0,-2), Vector3(1,0,0))
	add_whirlpool(35, Vector3(-45,0,3), Vector3(1,0,-0.2))
	add_iceberg(40, Vector3(0,0,-40), Vector3(0,0,1), 2, 1)
	# Wave 2 - Haul Away Hamish [Anchor focus]
	add_whirlpool(60, Vector3(-30,0,1), Vector3(1,0,0), 1.7, 3)
	add_whirlpool(60, Vector3(30,0,0), Vector3(-1,0,0), 4, 1)
	add_whirlpool(60, Vector3(40,0,1), Vector3(-1,0,0), 4, 1)
	add_iceberg(80, Vector3(0,0,40), Vector3(0,0,-1), 3, 1)
	add_iceberg(80, Vector3(20,0,50), Vector3(0,0,-1), 3, 1)
	add_iceberg(80, Vector3(-20,0,60), Vector3(0,0,-1), 3, 1)
	add_whirlpool(95, Vector3(30,0,0), Vector3(-1,0,0), 1.7, 3)
	add_whirlpool(100, Vector3(-30,0,0), Vector3(1,0,0), 1.7, 3)
	add_iceberg(120, Vector3(0,0,-40), Vector3(0,0,1), 2, 1)
	add_iceberg(120, Vector3(20,0,-65), Vector3(0,0,1), 2, 1)
	add_iceberg(120, Vector3(-20,0,-65), Vector3(0,0,1), 2, 1)
	# Wave 3 - Northwest Passage [Icebergs and cannons]
	add_iceberg(150, Vector3(0,0,40), Vector3(0,0,-1), 2, 1)
	add_iceberg(150, Vector3(0,0,60), Vector3(0,0,-1), 2, 1)
	add_iceberg(150, Vector3(20,0,65), Vector3(0,0,-1), 2, 1)
	add_iceberg(150, Vector3(-20,0,65), Vector3(0,0,-1), 2, 1)
	add_iceberg(150, Vector3(0,0,75), Vector3(0,0,-1), 4, 0.5)
	add_iceberg(150, Vector3(10,0,65), Vector3(0,0,-1), 4, 0.5)
	add_whirlpool(155, Vector3(-30,0,1), Vector3(1,0,-0.1), 4, .7)
	add_whirlpool(160, Vector3(30,0,-3), Vector3(-1,0,0.2), 4, 1)
	add_iceberg(165, Vector3(0,0,40), Vector3(0,0,-1), 3, 1)
	add_iceberg(165, Vector3(10,0,50), Vector3(0,0,-1), 3, 0.5)
	add_iceberg(180, Vector3(0,0,40), Vector3(0,0,-1), 3, .7)
	add_iceberg(180, Vector3(0,0,60), Vector3(0,0,-1), 3, .7)
	add_iceberg(180, Vector3(20,0,65), Vector3(0,0,-1), 3, .7)
	add_iceberg(180, Vector3(-20,0,65), Vector3(0,0,-1), 3, .7)
	add_whirlpool(185, Vector3(30,0,-3), Vector3(-1,0,0.2))
	add_whirlpool(185, Vector3(40,0,2), Vector3(-1,0,0.1))
	add_whirlpool(185, Vector3(-35,0,-2), Vector3(1,0,0))
	add_whirlpool(185, Vector3(-45,0,3), Vector3(1,0,-0.2))
	add_iceberg(190, Vector3(0,0,-40), Vector3(0,0,1), 2, 1)
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
