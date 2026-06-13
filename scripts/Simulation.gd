class_name Simulation
extends Node

const RouteData = preload("res://scripts/models/RouteData.gd")

signal tick_complete

var game_state: Node
var tick_timer: Timer

func setup(state: Node) -> void:
	game_state = state
	tick_timer = Timer.new()
	tick_timer.wait_time = 3.0
	tick_timer.autostart = true
	tick_timer.timeout.connect(_on_tick)
	add_child(tick_timer)

func _process(delta: float) -> void:
	if game_state == null: return
	for route in game_state.routes:
		var origin = game_state.get_settlement(route.origin_id)
		var culture = game_state.cultures.get(origin.culture_id, {}) if origin else {}
		var bonus := float(culture.get("route_speed_bonus", 0.0))
		route.progress += delta * route.speed * (1.0 + bonus)
		if route.progress >= 1.0:
			route.progress = 0.0
			_move_goods(route)
	game_state.emit_signal("state_changed")

func _on_tick() -> void:
	for settlement in game_state.settlements.values():
		_produce(settlement)
		_consume(settlement)
		_update_growth_pressure(settlement)
	emit_signal("tick_complete")
	game_state.emit_signal("state_changed")

func _produce(settlement) -> void:
	var industry: Dictionary = game_state.industries.get(settlement.industry_id, {})
	var resource := str(industry.get("produces", "food"))
	var amount: float = float(industry.get("amount", 1.0)) * float(settlement.level)
	var mayor: Dictionary = game_state.mayors.get(settlement.mayor_id, {})
	var culture: Dictionary = game_state.cultures.get(settlement.culture_id, {})
	amount *= 1.0 + float(mayor.get("production_bonus", 0.0))
	if resource == "food": amount *= 1.0 + float(culture.get("food_bonus", 0.0))
	if resource == "stone": amount *= 1.0 + float(culture.get("stone_bonus", 0.0))
	settlement.storage[resource] = float(settlement.storage.get(resource, 0.0)) + amount

func _consume(settlement) -> void:
	settlement.shortages.clear()
	for resource in settlement.needs.keys():
		var amount: float = float(settlement.needs[resource]) * float(settlement.level)
		var available := float(settlement.storage.get(resource, 0.0))
		if available >= amount:
			settlement.storage[resource] = available - amount
		else:
			settlement.storage[resource] = 0.0
			settlement.shortages[resource] = amount - available
	var mayor: Dictionary = game_state.mayors.get(settlement.mayor_id, {})
	settlement.happiness += 2.0 if settlement.shortages.is_empty() else -5.0 * settlement.shortages.size()
	settlement.happiness *= 1.0 + float(mayor.get("happiness_bonus", 0.0))
	settlement.happiness = clamp(settlement.happiness, 0.0, 100.0)
	settlement.corruption = clamp(settlement.corruption + float(mayor.get("corruption_bonus", 0.0)), 0.0, 100.0)

func _update_growth_pressure(settlement) -> void:
	if settlement.shortages.is_empty() and settlement.happiness > 65.0:
		settlement.population += settlement.level
	elif settlement.happiness < 25.0:
		settlement.population = max(5, settlement.population - 1)

func _move_goods(route: RouteData) -> void:
	var origin = game_state.get_settlement(route.origin_id)
	var destination = game_state.get_settlement(route.destination_id)
	if origin == null or destination == null: return
	var available := int(floor(float(origin.storage.get(route.resource, 0.0))))
	var moved = min(route.quantity, available)
	if moved <= 0: return
	origin.storage[route.resource] = float(origin.storage.get(route.resource, 0.0)) - moved
	destination.storage[route.resource] = float(destination.storage.get(route.resource, 0.0)) + moved

func create_route(origin_id: String, destination_id: String, resource: String) -> void:
	var route := RouteData.new({"id": "route_%d" % Time.get_unix_time_from_system(), "origin": origin_id, "destination": destination_id, "resource": resource})
	game_state.routes.append(route)
	game_state.emit_signal("state_changed")
