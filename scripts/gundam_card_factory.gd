class_name GundamCardFactory
extends CardFactory

## Card scene to instantiate (must be a GundamCard scene).
@export var card_scene: PackedScene
## Back face texture shared by all cards.
@export var back_image: Texture2D

# Internal card database: UPPERCASE code -> {info: Dictionary, set_dir: String}
var _card_db: Dictionary = {}
# Texture cache: UPPERCASE code -> Texture2D
var _texture_cache: Dictionary = {}


## Called by CardManager._ready() (or manually from gcg_game.gd).
## Scans all sets_data sub-directories and populates _card_db.
func preload_card_data() -> void:
	var root = "res://sets_data"
	var dir = DirAccess.open(root)
	if dir == null:
		push_error("GundamCardFactory: cannot open " + root)
		return
	dir.list_dir_begin()
	var entry = dir.get_next()
	while entry != "":
		if dir.current_is_dir() and not entry.begins_with("."):
			_load_set(root + "/" + entry, entry)
		entry = dir.get_next()
	dir.list_dir_end()
	print("GundamCardFactory: indexed %d cards" % _card_db.size())


func _load_set(set_path: String, set_name: String) -> void:
	var json_path = set_path + "/" + set_name + ".json"
	if not FileAccess.file_exists(json_path):
		return
	var file = FileAccess.open(json_path, FileAccess.READ)
	if file == null:
		return
	var text = file.get_as_text()
	file.close()
	var json = JSON.new()
	if json.parse(text) != OK:
		push_error("GundamCardFactory: failed to parse " + json_path)
		return
	var data = json.data
	if not data is Array:
		return
	for card_data in data:
		if card_data.has("code"):
			var code = str(card_data["code"]).to_upper()
			_card_db[code] = {
				"info": card_data,
				"set_dir": set_path + "/"
			}


## Returns (and caches) the front-face texture for a given card code.
func get_card_texture(card_code: String) -> Texture2D:
	var upper = card_code.to_upper()
	if _texture_cache.has(upper):
		return _texture_cache[upper]
	if not _card_db.has(upper):
		push_error("GundamCardFactory: unknown card '%s'" % card_code)
		return null
	var entry = _card_db[upper]
	var img_path = entry["set_dir"] + str(entry["info"].get("front_image", ""))
	var tex = load(img_path) as Texture2D
	if tex == null:
		push_error("GundamCardFactory: texture not found at " + img_path)
		return null
	_texture_cache[upper] = tex
	return tex


## Creates a GundamCard node for the given card code and adds it to target.
func create_card(card_code: String, target: CardContainer) -> Card:
	var upper = card_code.to_upper()
	if not _card_db.has(upper):
		push_error("GundamCardFactory: unknown card '%s'" % card_code)
		return null

	if card_scene == null:
		push_error("GundamCardFactory: card_scene not assigned")
		return null

	var card_info = _card_db[upper]["info"]
	var front_tex = get_card_texture(upper)
	if front_tex == null:
		return null

	var card = card_scene.instantiate() as GundamCard
	if card == null:
		push_error("GundamCardFactory: card_scene is not a GundamCard")
		return null

	if not target._card_can_be_added([card]):
		card.queue_free()
		return null

	card.card_info = card_info
	card.card_size  = card_size

	var cards_node = target.get_node("Cards")
	cards_node.add_child(card)
	target.add_card(card)

	card.card_name = str(card_info.get("name", upper))
	card.set_faces(front_tex, back_image)
	card.setup_from_json(card_info)

	return card
