class_name TurnProcessor extends RefCounted
## Abstract base class for turn processors
## Ensures consistent interface across all turn processing logic

signal turn_completed()
signal turn_action_executed(action_result: ActionResult)

## Process the turn for the given context
## Must be implemented by subclasses
func process_turn(_context: CombatContext) -> void:
	assert(false, "process_turn() must be implemented by subclass")

## Check if this processor can handle the current turn
## Optional override for validation
func can_process_turn(_context: CombatContext) -> bool:
	return true

## Clean up any resources after turn processing
## Optional override for cleanup
func cleanup() -> void:
	pass