## stage_generator.gd
## Generates a StageInstance from a StageTemplateResource
class_name StageGenerator
extends Resource

## Public entry point
static func generate(_stage_number: int, template: StageTemplateResource, rng_seed: int, available_rooms: Array[RoomResource], recent_history: Array[RoomResource]) -> StageInstance:
    var instance := StageInstance.new()
    instance.template = template
    instance.generation_seed = rng_seed

    var rng := RandomNumberGenerator.new()
    rng.seed = rng_seed

    if template.floors < 1:
        push_error("StageGenerator: template floors < 1; forcing 1")
        template.floors = 1

    var total_rooms := template.floors
    var boss_room_count := 1
    var non_boss_slots := total_rooms - boss_room_count
    var reserved_pre_boss_index := -1
    if template.has_pre_boss_tag() and non_boss_slots > 1:
        reserved_pre_boss_index = non_boss_slots - 1  ## last non-boss slot

    # Filter candidate rooms (exclude disallowed tags)
    var candidates: Array[RoomResource] = []
    for room in available_rooms:
        if _room_allowed(room, template):
            candidates.append(room)

    # Build tag -> rooms map
    # Tag map: tag -> Array[RoomResource] (untyped dict because nested typed collections not supported)
    var tag_map: Dictionary = {}
    for t in StageTags.all_tags():
        tag_map[t] = []
    for room in candidates:
        for tag in room.tags:
            if tag_map.has(tag):
                var arr: Array = tag_map[tag]
                arr.append(room)
                tag_map[tag] = arr

    var plan: Array[RoomResource] = []
    var tag_counts: Dictionary[StageTags.Tag, int] = {}
    for t in StageTags.all_tags():
        tag_counts[t] = 0

    # 1. Mandatory tag satisfaction
    for mandatory_tag: StageTags.Tag in template.mandatory_room_tags:
        var pool_variant: Variant = tag_map.get(mandatory_tag, [])
        var pool_array: Array = (pool_variant if typeof(pool_variant) == TYPE_ARRAY else [])
        var pool_cast: Array[RoomResource] = []
        for item: Variant in pool_array:
            if item is RoomResource:
                pool_cast.append(item)
        var chosen := _pick_weighted(pool_cast, rng, recent_history)
        if not chosen:
            # Fallback: try any candidate not disallowed
            chosen = _fallback_pick(candidates, plan, mandatory_tag, rng)
            instance.integrity_ok = false
            push_error("StageGenerator: Mandatory tag %s not satisfied directly; fallback used" % StageTags.tag_name(mandatory_tag))
        if chosen:
            plan.append(chosen)
            _register_selection(chosen, tag_counts)

    # 2. Fill remaining non-boss slots (excluding reserved pre-boss)
    while plan.size() < non_boss_slots:
        var next_index := plan.size()
        var is_pre_boss_slot := reserved_pre_boss_index == next_index
        var picked: RoomResource = null
        if is_pre_boss_slot and template.has_pre_boss_tag():
            var pre_pool_variant: Variant = tag_map.get(template.pre_boss_room_tag, [])
            var pre_pool_array: Array = (pre_pool_variant if typeof(pre_pool_variant) == TYPE_ARRAY else [])
            var pre_cast: Array[RoomResource] = []
            for p: Variant in pre_pool_array:
                if p is RoomResource:
                    pre_cast.append(p)
            picked = _pick_weighted(pre_cast, rng, recent_history)
            if not picked:
                # Fallback: any REST or SHOP if pre-boss tag not available
                var fallback_tags: Array[StageTags.Tag] = [StageTags.Tag.REST, StageTags.Tag.SHOP]
                for ft: StageTags.Tag in fallback_tags:
                    var ft_pool_variant: Variant = tag_map.get(ft, [])
                    var ft_pool_array: Array = (ft_pool_variant if typeof(ft_pool_variant) == TYPE_ARRAY else [])
                    var ft_cast: Array[RoomResource] = []
                    for fp: Variant in ft_pool_array:
                        if fp is RoomResource:
                            ft_cast.append(fp)
                    picked = _pick_weighted(ft_cast, rng, recent_history)
                    if picked:
                        break
                if not picked:
                    picked = _fallback_any(candidates, plan, rng)
                    instance.integrity_ok = false
                    push_error("StageGenerator: Pre-boss room fallback engaged")
        else:
            picked = _pick_optional(template, candidates, tag_map, rng, recent_history, tag_counts)
        if picked:
            plan.append(picked)
            _register_selection(picked, tag_counts)
        else:
            # If no room could be picked (should be rare), break to avoid infinite loop
            push_error("StageGenerator: No candidate selected for slot %d" % next_index)
            instance.integrity_ok = false
            break

    # 3. Boss selection
    var boss_room: RoomResource = null
    if template.boss_selector:
        boss_room = template.boss_selector.call()
    if not boss_room:
        boss_room = _fallback_any(candidates, plan, rng)
        instance.integrity_ok = false
        push_error("StageGenerator: Boss selector returned null; fallback room used")
    plan.append(boss_room)

    instance.planned_rooms = plan
    return instance

## Determine if a room is allowed under template constraints
static func _room_allowed(room: RoomResource, template: StageTemplateResource) -> bool:
    for t in room.tags:
        if template.is_tag_disallowed(t):
            return false
    return true

## Weighted pick from pool considering recent history
static func _pick_weighted(pool: Array[RoomResource], rng: RandomNumberGenerator, recent_history: Array[RoomResource]) -> RoomResource:
    if pool.is_empty():
        return null
    var weights: Array[float] = []
    var total := 0.0
    for room in pool:
        var w := room.rarity
        # Anti-repeat penalty
        for recent in recent_history:
            if recent == room:
                w *= 0.3
        if w <= 0:
            w = 0.0001
        weights.append(w)
        total += w
    if weights.is_empty():
        return null
    var pick := rng.randf() * total
    var accum := 0.0
    for i in range(pool.size()):
        accum += weights[i]
        if pick <= accum:
            return pool[i]
    return pool.back()  # fallback

## Optional tag picking combining template weights and repeats cap
static func _pick_optional(template: StageTemplateResource, candidates: Array[RoomResource], _tag_map: Dictionary, rng: RandomNumberGenerator, recent_history: Array[RoomResource], tag_counts: Dictionary[StageTags.Tag, int]) -> RoomResource:
    # Build a flat weighted list from all candidate rooms not yet violating caps
    var weighted: Array[Dictionary] = []  # {room, weight}
    for room in candidates:
        if room in weighted: # not possible; placeholder guard
            pass
        var skip := false
        for t in room.tags:
            var cap := template.get_max_repeats(t)
            if cap >= 0 and tag_counts.get(t, 0) >= cap:
                skip = true
                break
            if template.is_tag_disallowed(t):
                skip = true
                break
        if skip:
            continue
        # Derive combined weight: sum(template weight per tag) * rarity * anti-repeat
        var combined := 0.0
        for t in room.tags:
            combined += template.get_optional_weight(t)
        if combined <= 0.0:
            combined = 0.1
        combined *= room.rarity
        for recent in recent_history:
            if recent == room:
                combined *= 0.3
        weighted.append({"room": room, "weight": combined})
    if weighted.is_empty():
        return null
    var total := 0.0
    for e in weighted:
        total += e.weight
    var pick := rng.randf() * total
    var accum := 0.0
    for e in weighted:
        accum += e.weight
        if pick <= accum:
            return e.room
    return weighted.back().room

static func _fallback_pick(candidates: Array[RoomResource], current_plan: Array[RoomResource], _missing_tag: StageTags.Tag, rng: RandomNumberGenerator) -> RoomResource:
    # Try any candidate not yet in plan
    var pool: Array[RoomResource] = []
    for r in candidates:
        if r in current_plan:
            continue
        pool.append(r)
    if pool.is_empty():
        return null
    return pool[rng.randi_range(0, pool.size() - 1)]

static func _fallback_any(candidates: Array[RoomResource], current_plan: Array[RoomResource], rng: RandomNumberGenerator) -> RoomResource:
    return _fallback_pick(candidates, current_plan, StageTags.Tag.NONE, rng)

static func _register_selection(room: RoomResource, tag_counts: Dictionary[StageTags.Tag, int]) -> void:
    for t in room.tags:
        tag_counts[t] = tag_counts.get(t, 0) + 1
