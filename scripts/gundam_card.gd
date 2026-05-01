class_name GundamCard
extends Card

# --- Gundam TCG Specific Data ---
var rp_cost: int = 0
var hp: int = 0
var ap: int = 0
var color: String = ""
var card_type: String = "" # UNIT, PILOT, COMMAND, BASE, etc.
var card_trait: String = ""
var source_title: String = ""
var effect_text: String = ""

# --- State ---
var is_tapped: bool = false
var current_hp: int = 0

func _ready() -> void:
	super._ready() # Always call super on _ready when extending framework nodes
	current_hp = hp # Initialize current HP to max HP when deployed

# --- Core Mechanics ---
func tap_card() -> void:
	if not is_tapped:
		is_tapped = true
		# We will add visual rotation/animation in Phase 3
		print("Tapped card: ", name)

func untap_card() -> void:
	if is_tapped:
		is_tapped = false
		# We will reset visual rotation here in Phase 3
		print("Untapped card: ", name)

func setup_from_json(data: Dictionary) -> void:
	rp_cost = _parse_int(data.get("cost", "0"))
	hp      = _parse_int(data.get("hp",   "0"))
	ap      = _parse_int(data.get("ap",   "0"))
	color        = str(data.get("color",       ""))
	card_type    = str(data.get("cardType",    ""))
	card_trait   = str(data.get("trait",       ""))
	source_title = str(data.get("sourceTitle", ""))
	effect_text  = str(data.get("effect",      ""))
	current_hp   = hp


func _parse_int(value) -> int:
	if value == null:
		return 0
	var s = str(value).strip_edges()
	if s == "-" or s == "":
		return 0
	if s.begins_with("+"):
		s = s.substr(1)
	return s.to_int() if s.is_valid_int() else 0
