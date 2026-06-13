class_name CultureData
extends RefCounted

var display_name: String
var food_bonus: float
var stone_bonus: float
var route_speed_bonus: float

func _init(data: Dictionary = {}) -> void:
	display_name = str(data.get("name", "Settlers"))
	food_bonus = float(data.get("food_bonus", 0.0))
	stone_bonus = float(data.get("stone_bonus", 0.0))
	route_speed_bonus = float(data.get("route_speed_bonus", 0.0))
