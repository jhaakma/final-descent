## stage_template_resource.gd
## Minimal StageTemplateResource for Phase 1 stage generation
class_name StageTemplateResource
extends Resource

@export var floors: int = 10                                                 ## total rooms including boss
@export var mandatory_room_tags: Array[StageTags.Tag] = []                    ## required ≥1 occurrences
@export var optional_tag_weights: Dictionary[StageTags.Tag, float] = {}       ## weighted fill distribution
@export var max_repeats_per_tag: Dictionary[StageTags.Tag, int] = {}          ## repetition caps per tag
@export var disallowed_tags: Array[StageTags.Tag] = []                        ## tags completely excluded
@export var boss_selector: Callable                                           ## () -> RoomResource
@export var pre_boss_room_tag: StageTags.Tag = StageTags.Tag.NONE             ## NONE = no pre-boss requirement

func is_tag_disallowed(tag: StageTags.Tag) -> bool:
    return tag in disallowed_tags

func get_optional_weight(tag: StageTags.Tag) -> float:
    if optional_tag_weights.has(tag):
        var value := optional_tag_weights[tag]
        return value
    return 1.0

func get_max_repeats(tag: StageTags.Tag) -> int:
    if max_repeats_per_tag.has(tag):
        var cap := max_repeats_per_tag[tag]
        return cap
    return -1  ## -1 = unlimited

func has_pre_boss_tag() -> bool:
    return pre_boss_room_tag != StageTags.Tag.NONE
