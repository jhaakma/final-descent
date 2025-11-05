# UIEvents.gd
# Global event bus for UI updates - decouples game logic from UI refresh calls
extends Node

## Emitted when player stats change (HP, attack, defense, etc.)
signal player_stats_changed

## Emitted when player inventory changes (items added/removed/equipped)
signal player_inventory_changed

## Emitted when player status effects change (applied, processed, removed)
signal player_status_effects_changed

## Request all UI elements to refresh completely
signal ui_refresh_requested

## Convenience method to trigger all player-related UI updates
func refresh_player_ui() -> void:
	player_stats_changed.emit()
	player_inventory_changed.emit()
	player_status_effects_changed.emit()

## Convenience method to request full UI refresh
func refresh_all_ui() -> void:
	ui_refresh_requested.emit()
	refresh_player_ui()
