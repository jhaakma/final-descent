class_name RoomType extends Object
## Room type enumeration for stage planning and room generation

enum Type {
    NONE = 0,
    COMBAT = 1,
    CHEST = 2,
    REST = 3,
    SHRINE = 4,
    SHOP = 5,
    BLACKSMITH = 6,
    MIMIC = 7,
    BOSS = 8,
    PRE_BOSS = 9,
    EVENT = 10,
    QUEST = 11
}

## Get display name for room type
static func get_display_name(room_type: Type) -> String:
    match room_type:
        Type.NONE:
            return "None"
        Type.COMBAT:
            return "Combat"
        Type.CHEST:
            return "Chest"
        Type.REST:
            return "Rest"
        Type.SHRINE:
            return "Shrine"
        Type.SHOP:
            return "Shop"
        Type.BLACKSMITH:
            return "Blacksmith"
        Type.MIMIC:
            return "Mimic"
        Type.BOSS:
            return "Boss"
        Type.PRE_BOSS:
            return "Pre-Boss"
        Type.EVENT:
            return "Event"
        Type.QUEST:
            return "Quest"
        _:
            return "Unknown"
