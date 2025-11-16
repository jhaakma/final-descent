class_name Rarity extends Object
## Item/room rarity enumeration

enum Type {
    COMMON = 0,
    UNCOMMON = 1,
    RARE = 2,
    EPIC = 3,
    LEGENDARY = 4
}

## Get display name for rarity
static func get_display_name(rarity: Type) -> String:
    match rarity:
        Type.COMMON:
            return "Common"
        Type.UNCOMMON:
            return "Uncommon"
        Type.RARE:
            return "Rare"
        Type.EPIC:
            return "Epic"
        Type.LEGENDARY:
            return "Legendary"
        _:
            return "Unknown"

## Get relative weight for rarity (for weighted random selection)
static func get_weight(rarity: Type) -> float:
    match rarity:
        Type.COMMON:
            return 1.0
        Type.UNCOMMON:
            return 0.5
        Type.RARE:
            return 0.25
        Type.EPIC:
            return 0.1
        Type.LEGENDARY:
            return 0.05
        _:
            return 1.0
