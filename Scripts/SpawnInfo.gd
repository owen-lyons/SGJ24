class_name SpawnInfo

enum EHazard {NONE, WHIRLPOOL, ICEBERG}

export (EHazard) var hazard_type = EHazard.NONE
var spawned = false
var spawn_at_time : float
var spawn_position : Vector3
var move_dir : Vector3
var move_speed : float
var scale : Vector3
