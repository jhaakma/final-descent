#Abstract class representing an option in the options menu
class_name Option extends Resource

func get_display_name() -> String:
    return "Unnamed Option"

func get_confirmation_message() -> String:
    return "Are you sure you want to execute this option?"

func get_executed_message() -> String:
    return "Successfully executed option."

func execute() -> void:
    # To be overridden by subclasses
    pass