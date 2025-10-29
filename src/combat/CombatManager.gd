class_name CombatStateManager extends RefCounted
## Manages combat state transitions and turn order using signal-based communication
## Single responsibility: Only state management, no game logic implementation

signal state_changed(new_state: State, context: CombatContext)
signal combat_started(context: CombatContext)
signal player_turn_started(context: CombatContext)
signal enemy_turn_started(context: CombatContext)
signal turn_ended(context: CombatContext)
signal combat_ended(context: CombatContext, victory: bool)

enum State {
	COMBAT_START,
	PLAYER_TURN,
	ENEMY_TURN,
	TURN_END,
	COMBAT_END
}

var current_state: State = State.COMBAT_START
var context: CombatContext
var last_turn_was_player: bool = false  # Track who went last for proper alternation

func _init(combat_context: CombatContext) -> void:
	context = combat_context
	# Don't connect to context_changed - it can cause infinite loops
	# We'll check combat end conditions manually at appropriate times

func start_combat() -> void:
	current_state = State.COMBAT_START
	_emit_state_change()
	combat_started.emit(context)

	# Determine who goes first
	if context.enemy_first:
		transition_to_enemy_turn()
	else:
		transition_to_player_turn()

func transition_to_player_turn() -> void:
	if _can_transition_to(State.PLAYER_TURN):
		current_state = State.PLAYER_TURN
		last_turn_was_player = true
		_emit_state_change()
		player_turn_started.emit(context)

func transition_to_enemy_turn() -> void:
	if _can_transition_to(State.ENEMY_TURN):
		current_state = State.ENEMY_TURN
		last_turn_was_player = false
		_emit_state_change()
		enemy_turn_started.emit(context)

func transition_to_turn_end() -> void:
	if _can_transition_to(State.TURN_END):
		current_state = State.TURN_END
		context.increment_turn()
		_emit_state_change()
		turn_ended.emit(context)

		# Check for combat end, otherwise continue to next turn
		if not _check_combat_end_conditions():
			_continue_to_next_turn()

func end_combat(victory: bool) -> void:
	current_state = State.COMBAT_END
	context.end_combat()
	_emit_state_change()
	combat_ended.emit(context, victory)

func get_current_state() -> State:
	return current_state

func _emit_state_change() -> void:
	state_changed.emit(current_state, context)

func _can_transition_to(new_state: State) -> bool:
	# Validate state transitions
	match current_state:
		State.COMBAT_START:
			return new_state in [State.PLAYER_TURN, State.ENEMY_TURN]
		State.PLAYER_TURN:
			return new_state in [State.TURN_END, State.COMBAT_END]
		State.ENEMY_TURN:
			return new_state in [State.TURN_END, State.COMBAT_END]
		State.TURN_END:
			return new_state in [State.PLAYER_TURN, State.ENEMY_TURN, State.COMBAT_END]
		State.COMBAT_END:
			return false  # Terminal state
	return false

func _check_combat_end_conditions() -> bool:
	if context.is_combat_over():
		var victory: bool = context.get_combat_winner() == "player"
		end_combat(victory)
		return true
	return false

func _continue_to_next_turn() -> void:
	# Determine next turn based on current state and combat logic
	match current_state:
		State.TURN_END:
			# Check if either participant should skip their turn
			if context.player.should_skip_turn():
				transition_to_enemy_turn()
			elif context.enemy.should_skip_turn():
				transition_to_player_turn()
			else:
				# Normal turn alternation - opposite of who went last
				if last_turn_was_player:
					transition_to_enemy_turn()
				else:
					transition_to_player_turn()
