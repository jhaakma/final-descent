class_name CombatStateManager extends RefCounted
## Manages combat state transitions with clear round/turn semantics
## ROUND = Complete cycle where both player and enemy have acted
## TURN = Individual actor's action within a round

signal state_changed(new_state: State, context: CombatContext)
signal combat_started(context: CombatContext)
signal player_turn_started(context: CombatContext)
signal enemy_turn_started(context: CombatContext)
signal round_ended(context: CombatContext)
signal combat_ended(context: CombatContext, victory: bool)

enum State {
    COMBAT_START,
    PLAYER_TURN,
    ENEMY_TURN,
    ROUND_END,
    COMBAT_END
}

var current_state: State = State.COMBAT_START
var context: CombatContext
var round_number: int = 1
var turns_this_round: int = 0  # Track how many actors have acted this round

func _init(combat_context: CombatContext) -> void:
    context = combat_context

func start_combat() -> void:
    current_state = State.COMBAT_START
    round_number = 1
    turns_this_round = 0
    _emit_state_change()
    combat_started.emit(context)

    # Process ROUND_START effects for new round
    _process_round_start_effects()

    # Determine who goes first
    if context.enemy_first:
        transition_to_enemy_turn()
    else:
        transition_to_player_turn()

func transition_to_player_turn() -> void:
    if _can_transition_to(State.PLAYER_TURN):
        current_state = State.PLAYER_TURN
        _emit_state_change()
        player_turn_started.emit(context)

func transition_to_enemy_turn() -> void:
    if _can_transition_to(State.ENEMY_TURN):
        current_state = State.ENEMY_TURN
        _emit_state_change()
        enemy_turn_started.emit(context)

func end_current_turn() -> void:
    """Call this when an actor has finished their turn"""
    turns_this_round += 1
    print("DEBUG: Turn ended, turns_this_round = ", turns_this_round)

    # Check for combat end first
    if _check_combat_end_conditions():
        return

    # If both actors have acted this round, end the round
    if turns_this_round >= 2:
        print("DEBUG: Round complete, transitioning to round end")
        transition_to_round_end()
    else:
        # Continue to next actor's turn
        _continue_to_next_actor()

func transition_to_round_end() -> void:
    if _can_transition_to(State.ROUND_END):
        current_state = State.ROUND_END

        # Process ROUND_END status effects once per round
        _process_round_end_effects()

        _emit_state_change()
        round_ended.emit(context)

        # Check for combat end, otherwise start next round
        if not _check_combat_end_conditions():
            _start_next_round()

func _start_next_round() -> void:
    """Start a new round after the previous one has ended"""
    round_number += 1
    turns_this_round = 0
    context.increment_turn()  # This tracks overall game turns

    # Process ROUND_START effects for new round
    _process_round_start_effects()

    # Determine who goes first this round (could add initiative system here)
    if context.enemy_first:
        transition_to_enemy_turn()
    else:
        transition_to_player_turn()

func _continue_to_next_actor() -> void:
    """Continue to the next actor's turn within the current round"""
    match current_state:
        State.PLAYER_TURN:
            # Player finished, now enemy's turn (if not skipping)
            if context.enemy.should_skip_turn():
                # Enemy skips, count as their turn and potentially end round
                turns_this_round += 1
                if turns_this_round >= 2:
                    transition_to_round_end()
                else:
                    # This shouldn't happen in a 2-actor system
                    transition_to_player_turn()
            else:
                transition_to_enemy_turn()

        State.ENEMY_TURN:
            # Enemy finished, now player's turn (if not skipping)
            if context.player.should_skip_turn():
                # Player skips, count as their turn and potentially end round
                turns_this_round += 1
                if turns_this_round >= 2:
                    transition_to_round_end()
                else:
                    # This shouldn't happen in a 2-actor system
                    transition_to_enemy_turn()
            else:
                transition_to_player_turn()

func _process_round_start_effects() -> void:
    """Process effects that trigger at the start of each round"""
    if context.player.is_alive():
        context.player.process_status_effects_at_timing(EffectTiming.Type.ROUND_START, round_number)
    if context.enemy.is_alive():
        context.enemy.process_status_effects_at_timing(EffectTiming.Type.ROUND_START, round_number)

func _process_round_end_effects() -> void:
    """Process effects that trigger at the end of each round (like poison damage)"""
    print("DEBUG: Processing round end effects for round ", round_number)
    if context.player.is_alive():
        print("DEBUG: Processing player ROUND_END effects")
        context.player.process_status_effects_at_timing(EffectTiming.Type.ROUND_END, round_number)
    if context.enemy.is_alive():
        print("DEBUG: Processing enemy ROUND_END effects")
        context.enemy.process_status_effects_at_timing(EffectTiming.Type.ROUND_END, round_number)

func end_combat(victory: bool) -> void:
    print("DEBUG: Combat ending - processing any remaining ROUND_END effects")

    # Process any remaining ROUND_END effects before combat ends
    if context.player.is_alive():
        print("DEBUG: Processing player final ROUND_END effects")
        context.player.process_status_effects_at_timing(EffectTiming.Type.ROUND_END, round_number)

    if context.enemy.is_alive():
        print("DEBUG: Processing enemy final ROUND_END effects")
        context.enemy.process_status_effects_at_timing(EffectTiming.Type.ROUND_END, round_number)

    current_state = State.COMBAT_END
    context.end_combat()
    _emit_state_change()
    combat_ended.emit(context, victory)

func get_current_state() -> State:
    return current_state

func get_current_round() -> int:
    return round_number

func _emit_state_change() -> void:
    state_changed.emit(current_state, context)

func _can_transition_to(new_state: State) -> bool:
    # Validate state transitions
    match current_state:
        State.COMBAT_START:
            return new_state in [State.PLAYER_TURN, State.ENEMY_TURN]
        State.PLAYER_TURN:
            return new_state in [State.ENEMY_TURN, State.ROUND_END, State.COMBAT_END]
        State.ENEMY_TURN:
            return new_state in [State.PLAYER_TURN, State.ROUND_END, State.COMBAT_END]
        State.ROUND_END:
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
