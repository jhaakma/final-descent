class_name DamageType extends RefCounted

enum Type {
    PHYSICAL,
    POISON,
    FIRE,
    SHOCK,
    ICE,
    DARK,
    HOLY
}

# Human-readable names for damage types
static var type_names := {
    Type.PHYSICAL: "Physical",
    Type.POISON: "Poison",
    Type.FIRE: "Fire",
    Type.SHOCK: "Shock",
    Type.ICE: "Ice",
    Type.DARK: "Dark",
    Type.HOLY: "Holy"
}


# Colors for UI display of damage types
static var type_colors := {
    Type.PHYSICAL: "#a1a1a1ff",  # Light gray
    Type.POISON: "#8cbd3dff",    # Green
    Type.FIRE: "#ff5f2fff",      # Red-orange
    Type.SHOCK: "#fff568ff",     # Yellow
    Type.ICE: "#71ffe0ff",       # Light blue
    Type.DARK: "#653d80ff",      # Dark purple
    Type.HOLY: "#ffdb67ff"       # Golden yellow
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