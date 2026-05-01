extends Node


var game_scene = preload("res://scenes/main_game/gcg_game.tscn")
var statistics_scene = preload("res://scenes/menu/statistics.tscn")
var record_manager_scene = preload("res://scenes/local_db/record_manager.tscn")


@onready var seed_node = $Singleplayer/Seed
@onready var seed_warning = $SeedWarning
@onready var credits_node = $Credits2


func _ready() -> void:
	_set_ui_buttons()
	_set_record_manager_scene()


func _set_ui_buttons() -> void:
	var button_singleplayer = $Singleplayer
	button_singleplayer.connect("pressed", _new_game)
	var button_multiplayer = $Multiplayer
	button_multiplayer.connect("pressed", _new_game)
	var button_statistics = $Statistics
	button_statistics.disabled = true
	var button_credits = $Credits
	button_credits.connect("pressed", _pop_credits)
	var button_exit = $Exit
	button_exit.connect("pressed", _exit)


func _set_record_manager_scene() -> void:
	var record_manager_instance = record_manager_scene.instantiate()
	get_tree().root.add_child.call_deferred(record_manager_instance)


func _get_seed() -> int:
	var text = seed_node.text
	if text == "" or text == "-1":
		return randi() % 1000000 + 1
	
	if not text.is_valid_int():
		return 0
		
	var game_seed = text.to_int()
	if game_seed >= 1 and game_seed <= 1000000:
		return game_seed
	
	return 0


func _new_game() -> void:
	var game_seed = _get_seed()
	if game_seed == 0:
		seed_warning.popup_centered()
		return
	
	var game_instance = game_scene.instantiate()
	game_instance.game_seed = game_seed
	get_tree().root.add_child(game_instance)
	game_instance.new_game()
	get_node("/root/Menu").queue_free()


# TODO: implement multiplayer game start
func _new_multiplayer_game() -> void:
	pass


func _go_to_statistics() -> void:
	var statistics_instance = statistics_scene.instantiate()
	get_tree().root.add_child(statistics_instance)
	get_node("/root/Menu").queue_free()
	

func _pop_credits() -> void:
	credits_node.popup_centered()
	

func _exit() -> void:
	get_tree().quit()
