class_name DamageType extends RefCounted

enum Type {
    BLUNT,
    SLASHING,
    PIERCING,
    POISON,
    FIRE,
    SHOCK,
    ICE,
    DARK,
    HOLY
}

# Human-readable names for damage types
static var type_names := {
    Type.BLUNT: "Blunt",
    Type.SLASHING: "Slashing",
    Type.PIERCING: "Piercing",
    Type.POISON: "Poison",
    Type.FIRE: "Fire",
    Type.SHOCK: "Shock",
    Type.ICE: "Ice",
    Type.DARK: "Dark",
    Type.HOLY: "Holy"
}


# Colors for UI display of damage types
static var type_colors := {
    Type.BLUNT: "#b9b9b9ff",      # Light gray
    Type.SLASHING: "#b9b9b9ff",   # Dark goldenrod
    Type.PIERCING: "#b9b9b9ff",   # Slate gray
    Type.POISON: "#b3db72ff",     # Green
    Type.FIRE: "#fd815bff",       # Red-orange
    Type.SHOCK: "#fff568ff",      # Yellow
    Type.ICE: "#71ffe0ff",        # Light blue
    Type.DARK: "#856997ff",       # Dark purple
    Type.HOLY: "#fff4ceff"        # Golden yellow
}

# Get the display name for a damage type
static func get_type_name(type: Type) -> String:
    return type_names.get(type, "Unknown")

# Get the display color for a damage type
static func get_type_color(type: Type) -> Color:
    return type_colors.get(type, Color.WHITE)

# Check if a damage type is valid
static func is_valid_type(type: Type) -> bool:
    return type in type_names
