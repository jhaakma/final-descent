## stage_tags.gd
## Canonical StageTag enum & helpers to avoid string matching
class_name StageTags
extends Resource

enum Tag {
    NONE,
    COMBAT,
    CHEST,
    MIMIC,
    BLACKSMITH,
    REST,
    EVENT,
    SHOP,
    QUEST,
    PRE_BOSS,
    BOSS,
}

static func tag_name(tag: Tag) -> StringName:
    match tag:
        Tag.NONE:
            return "NONE"
        Tag.COMBAT:
            return "COMBAT"
        Tag.CHEST:
            return "CHEST"
        Tag.MIMIC:
            return "MIMIC"
        Tag.BLACKSMITH:
            return "BLACKSMITH"
        Tag.REST:
            return "REST"
        Tag.EVENT:
            return "EVENT"
        Tag.SHOP:
            return "SHOP"
        Tag.QUEST:
            return "QUEST"
        Tag.PRE_BOSS:
            return "PRE_BOSS"
        Tag.BOSS:
            return "BOSS"
        _:
            return "UNKNOWN"

static func all_tags() -> Array[Tag]:
    return [
        Tag.NONE,
        Tag.COMBAT,
        Tag.CHEST,
        Tag.MIMIC,
        Tag.BLACKSMITH,
        Tag.REST,
        Tag.EVENT,
        Tag.SHOP,
        Tag.QUEST,
        Tag.PRE_BOSS,
        Tag.BOSS,
    ]

static func is_valid(tag: Tag) -> bool:
    return tag in all_tags()
