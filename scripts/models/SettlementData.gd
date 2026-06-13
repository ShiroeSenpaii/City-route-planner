class_name SettlementData
extends RefCounted

var id: String
var name: String
var tile: Vector2i
var level: int = 1
var population: int = 20
var industry_id: String
var mayor_id: String
var house_id: String
var culture_id: String
var storage: Dictionary = {}
var needs: Dictionary = {}
var shortages: Dictionary = {}
var happiness: float = 60.0
var corruption: float = 0.0

func _init(data: Dictionary = {}) -> void:
	id = str(data.get("id", ""))
	name = str(data.get("name", id))
	var t: Dictionary = data.get("tile", {"x": 0, "y": 0})
	tile = Vector2i(int(t.get("x", 0)), int(t.get("y", 0)))
	level = int(data.get("level", 1))
	population = int(data.get("population", 20))
	industry_id = str(data.get("industry", ""))
	mayor_id = str(data.get("mayor", ""))
	house_id = str(data.get("house", ""))
	culture_id = str(data.get("culture", ""))
	storage = data.get("storage", {}).duplicate(true)
	needs = data.get("needs", {}).duplicate(true)
	shortages = data.get("shortages", {}).duplicate(true)
	happiness = float(data.get("happiness", 60.0))
	corruption = float(data.get("corruption", 0.0))

func level_name() -> String:
	return ["", "Hamlet", "Village", "Town"][clamp(level, 1, 3)]

func to_dict() -> Dictionary:
	return {"id": id, "name": name, "tile": {"x": tile.x, "y": tile.y}, "level": level, "population": population, "industry": industry_id, "mayor": mayor_id, "house": house_id, "culture": culture_id, "storage": storage, "needs": needs, "shortages": shortages, "happiness": happiness, "corruption": corruption}
