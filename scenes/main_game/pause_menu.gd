class_name PauseMenu
extends Control

signal resume_pressed
signal debug_pressed
signal restart_pressed
signal quit_to_menu_pressed


func _ready() -> void:
	anchor_right = 1.0
	anchor_bottom = 1.0
	mouse_filter = MOUSE_FILTER_STOP
	z_index = 100

	# Semi-transparent overlay
	var overlay = ColorRect.new()
	overlay.color = Color(0.0, 0.0, 0.0, 0.55)
	overlay.anchor_right = 1.0
	overlay.anchor_bottom = 1.0
	add_child(overlay)

	# Small centred panel
	var panel = PanelContainer.new()
	panel.anchor_left   = 0.5
	panel.anchor_right  = 0.5
	panel.anchor_top    = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left   = -110.0
	panel.offset_right  =  110.0
	panel.offset_top    = -130.0
	panel.offset_bottom =  130.0
	add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	var title = Label.new()
	title.text = "Paused"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 20)
	vbox.add_child(title)

	_add_button(vbox, "Resume",      _on_resume)
	_add_button(vbox, "Debug",       _on_debug)
	_add_button(vbox, "Restart",     _on_restart)
	_add_button(vbox, "Quit to Menu", _on_quit_to_menu)

	hide()


func _add_button(parent: VBoxContainer, label: String, callback: Callable) -> void:
	var btn = Button.new()
	btn.text = label
	btn.custom_minimum_size = Vector2(200, 44)
	btn.pressed.connect(callback)
	parent.add_child(btn)


func _on_resume() -> void:
	hide()
	resume_pressed.emit()


func _on_debug() -> void:
	hide()
	debug_pressed.emit()


func _on_restart() -> void:
	hide()
	restart_pressed.emit()


func _on_quit_to_menu() -> void:
	hide()
	quit_to_menu_pressed.emit()
