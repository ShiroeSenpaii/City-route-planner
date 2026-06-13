extends Node

const MapController = preload("res://scripts/MapController.gd")
const UIController = preload("res://scripts/UIController.gd")
const Simulation = preload("res://scripts/Simulation.gd")

var map_controller: MapController
var ui_controller: UIController
var simulation: Simulation
var auto_save_timer: Timer
var pending_route_origin := ""

func _ready() -> void:
	map_controller = MapController.new(); add_child(map_controller); map_controller.setup(GameState)
	ui_controller = UIController.new(); add_child(ui_controller); ui_controller.setup(GameState)
	simulation = Simulation.new(); add_child(simulation); simulation.setup(GameState)
	map_controller.settlement_tapped.connect(_on_settlement_tapped)
	ui_controller.create_route_pressed.connect(func(origin): pending_route_origin = origin)
	ui_controller.confirm_route_pressed.connect(_on_confirm_route)
	ui_controller.upgrade_pressed.connect(_on_upgrade)
	ui_controller.save_pressed.connect(func(): SaveManager.save_game(GameState))
	ui_controller.load_pressed.connect(func(): SaveManager.load_game(GameState))
	ui_controller.reset_pressed.connect(func(): SaveManager.reset_game(GameState))
	auto_save_timer = Timer.new(); auto_save_timer.wait_time = 30.0; auto_save_timer.autostart = true; auto_save_timer.timeout.connect(func(): SaveManager.save_game(GameState)); add_child(auto_save_timer)
	GameState.select_settlement("oakmere")

func _on_settlement_tapped(id: String) -> void:
	GameState.select_settlement(id)

func _on_confirm_route(destination_id: String, resource: String) -> void:
	if pending_route_origin != "" and pending_route_origin != destination_id:
		simulation.create_route(pending_route_origin, destination_id, resource)
	pending_route_origin = ""

func _on_upgrade(settlement_id: String) -> void:
	var settlement = GameState.get_settlement(settlement_id)
	if settlement == null or not ui_controller.can_upgrade(settlement): return
	if settlement.level == 1:
		settlement.storage["wood"] -= 5; settlement.storage["food"] -= 5
	else:
		settlement.storage["wood"] -= 10; settlement.storage["stone"] -= 8
	settlement.level += 1
	GameState.emit_signal("state_changed")
