class_name TileData
extends RefCounted

var x: int
var y: int
var terrain: String

func _init(data: Dictionary = {}) -> void:
	x = int(data.get("x", 0))
	y = int(data.get("y", 0))
	terrain = str(data.get("terrain", "plains"))

func to_dict() -> Dictionary:
	return {"x": x, "y": y, "terrain": terrain}
