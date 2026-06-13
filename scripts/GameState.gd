extends Node

const TileData = preload("res://scripts/models/TileData.gd")
const SettlementData = preload("res://scripts/models/SettlementData.gd")
const RouteData = preload("res://scripts/models/RouteData.gd")

signal state_changed
signal selection_changed(settlement_id: String)

var width: int = 5
var height: int = 4
var tiles: Array[TileData] = []
var settlements: Dictionary = {}
var routes: Array[RouteData] = []
var industries: Dictionary = {}
var mayors: Dictionary = {}
var houses: Dictionary = {}
var cultures: Dictionary = {}
var resources: Dictionary = {}
var selected_settlement_id: String = ""

func _ready() -> void:
	load_static_data()
	if settlements.is_empty():
		load_starting_map()

func read_json(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Missing JSON: " + path)
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	return parsed if typeof(parsed) == TYPE_DICTIONARY else {}

func load_static_data() -> void:
	resources.clear(); industries.clear(); mayors.clear(); houses.clear(); cultures.clear()
	for item in read_json("res://data/resources.json").get("resources", []): resources[str(item.get("id", ""))] = item
	for item in read_json("res://data/industries.json").get("industries", []): industries[str(item.get("id", ""))] = item
	for item in read_json("res://data/mayors.json").get("mayors", []): mayors[str(item.get("id", ""))] = item
	for item in read_json("res://data/noble_houses.json").get("houses", []): houses[str(item.get("id", ""))] = item
	for item in read_json("res://data/cultures.json").get("cultures", []): cultures[str(item.get("id", ""))] = item

func load_starting_map() -> void:
	var data := read_json("res://data/starting_map.json")
	width = int(data.get("width", 5)); height = int(data.get("height", 4))
	tiles.clear(); settlements.clear(); routes.clear()
	var rows: Array = data.get("tiles", [])
	for y in range(height):
		for x in range(width):
			tiles.append(TileData.new({"x": x, "y": y, "terrain": rows[y][x]}))
	for raw in data.get("settlements", []):
		var settlement := SettlementData.new(raw)
		settlements[settlement.id] = settlement
	emit_signal("state_changed")

func select_settlement(id: String) -> void:
	selected_settlement_id = id
	emit_signal("selection_changed", id)

func get_settlement(id: String) -> SettlementData:
	return settlements.get(id)

func to_dict() -> Dictionary:
	var settlement_data := []
	for settlement in settlements.values(): settlement_data.append(settlement.to_dict())
	var route_data := []
	for route in routes: route_data.append(route.to_dict())
	return {"width": width, "height": height, "tiles": tiles.map(func(t): return t.to_dict()), "settlements": settlement_data, "routes": route_data}

func apply_save(data: Dictionary) -> void:
	width = int(data.get("width", 5)); height = int(data.get("height", 4))
	tiles.clear(); settlements.clear(); routes.clear()
	for tile_data in data.get("tiles", []): tiles.append(TileData.new(tile_data))
	for settlement_data in data.get("settlements", []):
		var settlement := SettlementData.new(settlement_data)
		settlements[settlement.id] = settlement
	for route_data in data.get("routes", []): routes.append(RouteData.new(route_data))
	emit_signal("state_changed")
