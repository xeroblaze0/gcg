extends Node

# This will act as the global "Match Manager". 
# In Godot, you'll eventually make this an Autoload (Project -> Project Settings -> Autoloads)
# so it is always accessible from anywhere in your game via entirely decoupled logic.

enum Phase {
	START,
	DRAW,
	MAIN,
	COMBAT, # Attack declaration, defense, damage step
	END
}

enum GameResult {
	IN_PROGRESS,
	WIN,
	LOSE,
	DRAW
}

var turn_number: int = 1
var current_phase: Phase = Phase.START

# Player Resources
var p1_mana: int = 0
var p2_mana: int = 0

signal phase_changed(new_phase: Phase)
signal turn_ended(new_turn: int)

func _ready() -> void:
	print("Match State initialized. Turn ", turn_number)
	_start_turn()

func _start_turn() -> void:
	set_phase(Phase.START)
	# Untap step logic, etc.
	
	# Move to draw phase
	set_phase(Phase.DRAW)

func set_phase(new_phase: Phase) -> void:
	current_phase = new_phase
	phase_changed.emit(current_phase)
	print("Phase changed to: ", current_phase)

func end_turn() -> void:
	turn_number += 1
	turn_ended.emit(turn_number)
	_start_turn()
