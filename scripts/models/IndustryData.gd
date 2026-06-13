class_name IndustryData
extends RefCounted

var id: String
var name: String
var produces: String
var amount: float
var terrain: String

func _init(data: Dictionary = {}) -> void:
	id = str(data.get("id", ""))
	name = str(data.get("name", id))
	produces = str(data.get("produces", "food"))
	amount = float(data.get("amount", 3.0))
	terrain = str(data.get("terrain", "plains"))
