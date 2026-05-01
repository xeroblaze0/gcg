extends Node2D

const DECK_P1 := "res://deck_data/cyclops_team.json"
const DECK_P2 := "res://deck_data/jupitris.json"
const EX_BASE_ID := "EXBP-001"

var game_seed: int = 0

var _rng          := RandomNumberGenerator.new()
var _mulligan_used := false
var _p1_hand_ids  : Array = []   # 5 IDs currently shown in mulligan popup
var _p1_remaining : Array = []   # remaining IDs not yet on board

# Single shared factory — GundamCardFactory.new() avoids PackedScene cast issues.
var _factory: GundamCardFactory
var _mulligan_popup: MulliganPopup
var _pause_menu: PauseMenu

@onready var _player_cards   : CardManager = $PlayerCards
@onready var _opponent_cards  : CardManager = $OpponentCards
@onready var _player_deck               = $PlayerCards/PlayerDeck
@onready var _player_hand               = $PlayerCards/PlayerHand
@onready var _player_base               = $PlayerCards/PlayerBase
@onready var _opponent_deck             = $OpponentCards/OpponentDeck
@onready var _opponent_hand             = $OpponentCards/OpponentHand
@onready var _opponent_base             = $OpponentCards/OpponentBase


func _ready() -> void:
	# Direct class instantiation — no PackedScene cast required.
	_factory = GundamCardFactory.new()
	_factory.card_scene = preload("res://scenes/cards/gundam_card.tscn")
	_factory.back_image = preload("res://sets_data/gundam_back.png")
	_factory.card_size  = _player_cards.card_size
	add_child(_factory)
	_factory.preload_card_data()

	_mulligan_popup = preload("res://scenes/main_game/mulligan_popup.tscn").instantiate()
	$UI.add_child(_mulligan_popup)
	_mulligan_popup.kept.connect(_on_keep_hand)
	_mulligan_popup.mulliganed.connect(_on_mulligan)

	_pause_menu = PauseMenu.new()
	$UI.add_child(_pause_menu)
	_pause_menu.resume_pressed.connect(func(): pass)  # overlay hides itself
	_pause_menu.debug_pressed.connect(_on_debug)
	_pause_menu.restart_pressed.connect(_on_restart)
	_pause_menu.quit_to_menu_pressed.connect(_on_quit_to_menu)

	$UI/MenuButton.pressed.connect(_on_menu_button_pressed)


func new_game() -> void:
	_rng.seed = game_seed
	_mulligan_used = false

	var p1_deck := _load_deck(DECK_P1)
	var p2_deck := _load_deck(DECK_P2)
	_shuffle(p1_deck)
	_shuffle(p2_deck)

	# ── Opponent (AI – always keeps) ──────────────────────────────────────
	_place_card(EX_BASE_ID, _opponent_base, true)
	for i in range(6):
		_place_card(p2_deck[i], _shield_node($OpponentCards, i + 1), false)
	for i in range(6, 11):
		_place_card(p2_deck[i], _opponent_hand, false)   # AI hand face-down
	for i in range(11, p2_deck.size()):
		_place_card(p2_deck[i], _opponent_deck, false)

	# ── Player – shields & base placed now; hand deferred to mulligan ────
	_place_card(EX_BASE_ID, _player_base, true)
	for i in range(6):
		_place_card(p1_deck[i], _shield_node($PlayerCards, i + 1), false)
	_p1_hand_ids  = p1_deck.slice(6, 11)
	_p1_remaining = p1_deck.slice(11)

	_show_mulligan_popup()


# ── Mulligan helpers ──────────────────────────────────────────────────────

func _show_mulligan_popup() -> void:
	var textures: Array = []
	for id in _p1_hand_ids:
		textures.append(_factory.get_card_texture(id))
	_mulligan_popup.show_hand(textures, not _mulligan_used)


func _on_keep_hand() -> void:
	for id in _p1_hand_ids:
		_place_card(id, _player_hand, true)
	for id in _p1_remaining:
		_place_card(id, _player_deck, false)


func _on_mulligan() -> void:
	_mulligan_used = true
	_p1_remaining.append_array(_p1_hand_ids)
	_shuffle(_p1_remaining)
	_p1_hand_ids  = _p1_remaining.slice(0, 5)
	_p1_remaining = _p1_remaining.slice(5)
	_show_mulligan_popup()


# ── Utility ───────────────────────────────────────────────────────────────

func _place_card(card_id: String, container: Node, face_up: bool) -> void:
	var card := _factory.create_card(card_id, container as CardContainer)
	if card:
		card.show_front = face_up


func _shield_node(manager: CardManager, index: int) -> Node:
	var prefix := "Player" if manager == _player_cards else "Opponent"
	return manager.get_node(prefix + "Shield_" + str(index))


func _load_deck(path: String) -> Array:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("GcgGame: cannot open deck file: " + path)
		return []
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		push_error("GcgGame: failed to parse deck JSON: " + path)
		file.close()
		return []
	file.close()
	var result: Array = []
	for entry in json.data.get("cards", []):
		var id := str(entry.get("id", "")).to_upper()
		for _i in range(entry.get("count", 1)):
			result.append(id)
	return result


func _shuffle(arr: Array) -> void:
	for i in range(arr.size() - 1, 0, -1):
		var j := _rng.randi_range(0, i)
		var tmp = arr[i]
		arr[i] = arr[j]
		arr[j] = tmp


# ── Pause menu handlers ───────────────────────────────────────────────────

func _on_menu_button_pressed() -> void:
	_pause_menu.show()


func _on_debug() -> void:
	# TODO: open a debug inspector / state viewer
	pass


func _on_restart() -> void:
	# Clear the board and start a fresh game with the same seed.
	get_tree().reload_current_scene()


func _on_quit_to_menu() -> void:
	var menu_packed = load("res://scenes/menu/menu.tscn") as PackedScene
	if menu_packed == null:
		push_error("GcgGame: could not load menu.tscn")
		return
	var menu_instance = menu_packed.instantiate()
	get_tree().root.add_child(menu_instance)
	queue_free()
