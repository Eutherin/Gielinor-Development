debug_error_handler:
  type: world
  debug: false
  events:
    on script generates error:
      - if <context.script.name||invalid> == debug_wrapper:
        - determine <&c><context.message>
    on server generates exception:
      - if <context.script.name||invalid> == debug_wrapper:
        - determine <&c><context.message>
debug_wrapper:
  type: task
  debug: false
  item_spawns:
    - define contexttags item|entity|location
    - inject locally script
  entity_breaks_hanging:
    - define contexttags cause|breaker|hanging
    - inject locally script
  entity_damages_entity:
    - define contexttags entity|damager|cause|damage|final_damage|projectile|damage_type_map
    - inject locally script
  player_right_clicks_entity:
    - define contexttags entity|item|click_position
    - inject locally script
  player_clicks_fake_entity:
    - define contexttags entity|hand|click_type
    - inject locally script
  entity_changes_block:
    - define contexttags entity|location|old_material|new_material
    - inject locally script
  on_block being built:
    - define contexttags location|old_naterial|new_material
    - inject locally script
  block_burns:
    - define contexttags location|material
    - inject locally script
  block_dispenses_item:
    - define contexttags location|item|velocity
    - inject locally script
  block_fades:
    - define contexttags location|material
    - inject locally script
  block_falls:
    - define contexttags location|entity
    - inject locally script
  block_forms:
    - define contexttags location|material
    - inject locally script
  block_grows:
    - define contexttags location|material
    - inject locally script
  block_ignites:
    - define contexttags location|entity|origin|cause
    - inject locally script
  entity_death:
    - define contexttags entity|damager|message|cause|drops|xp
    - inject locally script
  enters_area:
    - define contexttags area|cause|to|from
    - inject locally script
  enters_biome:
    - define contexttags from|to|old_biome|new_biome
    - inject locally script
  on_player scrolls their hotbar:
    - define contexttags new_slot|previous_slot
    - inject locally script
  on_player breaks block:
    - define contexttags location|material|xp
    - inject locally script
  player_breaks held item:
    - define contexttags item|slot
    - inject locally script
  player_changes gamemode:
    - define contexttags gamemode
    - inject locally script
  changes_sign:
    - define contexttags location|new|old|material
    - inject locally script
  player_changes_world:
    - define contexttags origin_world|destination|world
    - inject locally script
  player_clicks_block:
    - define contexttags item|location|relative|click_type|hand
    - inject locally script
  player_clicks_in_inventory:
    - define contexttags item|inventory|clicked_inventory|cursor_item|click|slot_type|slot|raw_slot|is_shift_click|action|hotbar_button
    - inject locally script
  player_drags_in_inventory:
    - define contexttags item|inventory|clicked_inventory|slots|raw_slots
    - inject locally script
  player_kicked:
    - define contexttags message|reason|flying
    - inject locally script
  player_places_block:
    - define contexttags location|material|old_material|item_in_hand
    - inject locally script
  resource_pack_status:
    - define contexttags status
    - inject locally script
  command:
    - define contexttags command|raw_args|args|source_type|command_block_location|command_minecart
    - inject locally script
  script:
    - define event_header <context.event_header>
    - flag server <[event_header]>_debugging:++ duration:1s
    - define context "<list.include_single[<&b>you are seeing this because of your <&a><&lb><&3>debug<&b><&a><&rb> <&b>flag node.]>"
    - define context "<[context].include_single[<&e>single second fire rate<&6>: <&b><server.flag[<[event_header]>_debugging]>]>"
    - define context "<[context].include_single[<&6><&lt><&e>script.name<&6><&gt> <&3>| <&b><queue.script.name>]>"
    - define context "<[context].include_single[<&6><&lt><&e>queue.id<&6><&gt> <&3>| <&3>*<&b><queue.id.after_last[_]>]>"
    - foreach <list[cancelled|event_name].include[<[contexttags]>]> as:tag:
      - define tag_parsed <element[<&lt>context.<[tag]>||<&c>invalid<&gt>].parsed||<&c>invalid>
      - define context "<[context].include_single[<&6><&lt><&e>context<&6>.<&e><[tag]><&6><&gt> <&3>|<&b> <[tag_parsed]>]>"

    - if <[additional_context]||invalid> != invalid:
      - foreach <[additional_context]> key:name:
      - define context "<[context].include_single[<&e><[name]> <&3>|<&b> <[value]>]>"

    - define hover <[context].separated_by[<&nl>]>
    - define text "<&2>[<&a>event fired<&2>]<&b> hover for debug content<&3>."

    - announce to_console <[hover]>
    - narrate <&hover[<[hover]>]><[text]><&end_hover> targets:<server.online_players_flagged[behr.essentials.debugging]>

webget_test:
  type: task
  script:
    - define url https://discordapp.com/api/webhooks/713089103276802058/91jfto9mwsdcvxl9ge6lng4yjxe9r3zbfxpk5zozxushcgcsypqf4ic2te4r5maheuh_
    - ~webget <[url]> headers:user-agent/bear|content-type/application/json save:response
    - narrate <entry[response].failed>
    - narrate <entry[response].status>
    - narrate <entry[response].result>
