class_name RouteData
extends RefCounted

var id: String
var origin_id: String
var destination_id: String
var resource: String
var quantity: int = 2
var progress: float = 0.0
var speed: float = 0.25

func _init(data: Dictionary = {}) -> void:
	id = str(data.get("id", ""))
	origin_id = str(data.get("origin", ""))
	destination_id = str(data.get("destination", ""))
	resource = str(data.get("resource", "food"))
	quantity = int(data.get("quantity", 2))
	progress = float(data.get("progress", 0.0))
	speed = float(data.get("speed", 0.25))

func to_dict() -> Dictionary:
	return {"id": id, "origin": origin_id, "destination": destination_id, "resource": resource, "quantity": quantity, "progress": progress, "speed": speed}
