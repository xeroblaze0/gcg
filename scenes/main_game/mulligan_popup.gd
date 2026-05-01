class_name MulliganPopup
extends Control

signal kept
signal mulliganed

var _card_row: HBoxContainer
var _mulligan_btn: Button


func _ready() -> void:
	# Fill viewport
	anchor_right = 1.0
	anchor_bottom = 1.0
	mouse_filter = MOUSE_FILTER_STOP

	# Semi-transparent dark overlay
	var overlay = ColorRect.new()
	overlay.color = Color(0.0, 0.0, 0.0, 0.7)
	overlay.anchor_right = 1.0
	overlay.anchor_bottom = 1.0
	add_child(overlay)

	# Centered panel
	var panel = PanelContainer.new()
	panel.anchor_left   = 0.5
	panel.anchor_right  = 0.5
	panel.anchor_top    = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left   = -330.0
	panel.offset_right  =  330.0
	panel.offset_top    = -215.0
	panel.offset_bottom =  215.0
	add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	panel.add_child(vbox)

	# Title
	var title = Label.new()
	title.text = "Starting Hand"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 22)
	vbox.add_child(title)

	# Card image row (populated in show_hand())
	_card_row = HBoxContainer.new()
	_card_row.add_theme_constant_override("separation", 8)
	_card_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_card_row.custom_minimum_size = Vector2(0, 148)
	vbox.add_child(_card_row)

	# Instructions
	var info = Label.new()
	info.text = "You may mulligan once: return your hand to the bottom of your deck, reshuffle, and draw 5 new cards."
	info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info.custom_minimum_size = Vector2(600, 0)
	vbox.add_child(info)

	# Buttons
	var btn_row = HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.add_theme_constant_override("separation", 20)
	vbox.add_child(btn_row)

	var keep_btn = Button.new()
	keep_btn.text = "Keep Hand"
	keep_btn.custom_minimum_size = Vector2(150, 44)
	keep_btn.pressed.connect(_on_keep_pressed)
	btn_row.add_child(keep_btn)

	_mulligan_btn = Button.new()
	_mulligan_btn.text = "Mulligan"
	_mulligan_btn.custom_minimum_size = Vector2(150, 44)
	_mulligan_btn.pressed.connect(_on_mulligan_pressed)
	btn_row.add_child(_mulligan_btn)

	hide()


## Display the popup with the given card textures.
## Set can_mulligan=false to disable the Mulligan button (already used).
func show_hand(textures: Array, can_mulligan: bool) -> void:
	for child in _card_row.get_children():
		child.queue_free()
	for tex in textures:
		var tr = TextureRect.new()
		tr.texture = tex
		tr.custom_minimum_size = Vector2(100, 140)
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_card_row.add_child(tr)
	_mulligan_btn.disabled = not can_mulligan
	show()


func _on_keep_pressed() -> void:
	hide()
	kept.emit()


func _on_mulligan_pressed() -> void:
	hide()
	mulliganed.emit()
