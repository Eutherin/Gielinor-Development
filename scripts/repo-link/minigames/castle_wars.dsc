#$ GAMEMODES: night mode   | friendly fire | death explosion
#$            double speed | 1.8 combat    | NPCs
castle_wars_handler:
  type: world
  events:
    on player right clicks castle_wars_*_flag_entity:
      - determine passively cancelled

    on player joins flagged:gielinor.minigames.castle_wars.death_screen:
      - adjust <player> respawn
      - equip <player> head:air chest:air

    on player respawns flagged:gielinor.minigames.castle_wars.in_game:
      - determine passively cancelled
      - inject castle_wars_player_respawn

    on player respawns flagged:gielinor.minigames.castle_wars.death_screen:
      - inject castle_wars_player_respawn.after_game

    on player death flagged:gielinor.minigames.castle_wars.in_game:
      - inject castle_wars_player_death
      - inject castle_wars_player_death.message
      - determine passively NO_DROPS_OR_XP
      - determine passively KEEP_INV
      - determine passively NO_MESSAGE

    on player clicks block with:castle_wars_bandage priority:-1:
      - determine passively cancelled
      - ratelimit <player> 15t
      - inject castle_wars_bandage_task
      - inject castle_wars_bandage_task.heal

    on player right clicks item_frame:
      - determine passively cancelled
      - ratelimit <player> 15t
      - inject castle_wars_bandage_task
      - inject castle_wars_bandage_task.table_grab

    on player damages item_frame:
      - determine passively cancelled
      - ratelimit <player> 15t
      - inject castle_wars_bandage_task
      - inject castle_wars_bandage_task.table_grab

    on entity breaks hanging in:castle_wars:
      - determine cancelled

    on player right clicks barrel|crafting_table|smoker|anvil|chipped_anvil|spruce_fence_gate|brewing_stand|blast_furnace|chest|*trapdoor in:castle_wars priority:1:
      - determine cancelled

    on player damages castle_wars_barricade_hitbox_entity:
      - determine passively cancelled
      - if <context.projectile||invalid> != invalid:
        - remove <context.projectile>
      - run castle_wars_barricade_damage def:<context.entity>
  
    on player damages castle_wars_barricade_table_entity:
      - determine passively cancelled
      - inject castle_wars_barricade_entity
      - run castle_wars_barricade_entity.table_grab

    on player right clicks castle_wars_barricade_table_entity:
      - determine passively cancelled
      - inject castle_wars_barricade_entity
      - run castle_wars_barricade_entity.table_grab

    on player clicks block with:castle_wars_barricade:
      - determine passively cancelled
      - inject castle_wars_barricade_entity
      - run castle_wars_barricade_entity.place

    on player clicks block in:castle_wars_*_flag_click_area:
      - determine passively cancelled
      - inject castle_wars_flag_event.team_verification
      - inject castle_wars_flag_event.home_team_check
      - inject castle_wars_flag_event

    on player clicks block in:castle_wars_*_wooden_door_*:
      - determine passively cancelled
      - inject castle_wars_wooden_door

    on player clicks block in:castle_wars_*_portal_door_*:
      - inject castle_wars_portal_door

  #@on player clicks block in:castle_wars_collapsible_rocks:
  #@on player clicks block with:castle_wars_explosive_potion in:castle_wars_collapsible_rocks:
    on player clicks castle_wars_*_* in inventory:
      - determine cancelled

    on player drags castle_wars_*_* in inventory:
      - determine cancelled

    on server start:
      - ~run castle_wars_waiting_bar_setup
      - flag server gielinor.minigames.castle_wars.in_queue:!
      - yaml id:minigames load:minigames.yml

    on player damages player in:castle_wars_queue_room:
      - determine passively cancelled

    on player death in:castle_wars_queue_room:
      - determine cancelled

    after player enters castle_wars_queue_room:
      - inject castle_wars_queue.queue_process

    on player exits castle_wars_queue_room:
      - inject castle_wars_queue.player_exit

    after player enters castle_wars_hub:
      - inject castle_wars_queue.player_enter

    after player enters castle_wars_portal_*:
      - inject castle_wars_queue.player_item_requirement
      - inject castle_wars_queue.player_initiate

castle_wars_queue:
  type: task
  queue_process:
    - if <server.has_flag[gielinor.minigames.castle_wars.queue]>:
      - if !<server.has_flag[gielinor.minigames.castle_wars.start_time]>:
        - define bar <server.flag[gielinor.minigames.castle_wars.waiting_box]>
        - bossbar update castle_wars_queue_red progress:0 color:red title:<[bar]> players:<server.online_players_flagged[gielinor.minigames.castle_wars.in_queue].filter[has_flag[gielinor.minigames.castle_wars.team.red]]>
        - bossbar update castle_wars_queue_blue progress:0 color:blue title:<[bar]> players:<server.online_players_flagged[gielinor.minigames.castle_wars.in_queue].filter[has_flag[gielinor.minigames.castle_wars.team.blue]]>
    - else:
      - define bar <server.flag[gielinor.minigames.castle_wars.waiting_box]>
      - bossbar create castle_wars_queue_red progress:0 color:red title:<[bar]> players:<server.online_players_flagged[gielinor.minigames.castle_wars.in_queue].filter[has_flag[gielinor.minigames.castle_wars.team.red]]>
      - bossbar create castle_wars_queue_blue progress:0 color:blue title:<[bar]> players:<server.online_players_flagged[gielinor.minigames.castle_wars.in_queue].filter[has_flag[gielinor.minigames.castle_wars.team.blue]]>
      - flag server gielinor.minigames.castle_wars.queue
      - run castle_wars_queue
      - while !<cuboid[castle_wars_queue_room].players.is_empty>:
        - run castle_wars_portal_particles def:return
        - wait 3s

  player_item_requirement:
    - define portal <context.area.note_name.after_last[_]>
    - if <player.equipment_map.contains_any[helmet|chestplate]> && <[portal]> != return:
      - if !<player.has_flag[gielinor.message_rate_limit.castle_wars_equipment_requirement]>:
        - flag player gielinor.message_rate_limit.castle_wars_equipment_requirement duration:7s
        - narrate format:colorize_red "You can't wear hats, cloaks or helms in the arena."
      - adjust <player> velocity:<player.location.sub[<context.area.center.below[1.2]>].normalize.mul[1.2].with_y[0.3]>
      - playsound <player> sound:BLOCK_BEACON_DEACTIVATE
      - stop

  player_initiate:
    - playsound <player> sound:BLOCK_BEACON_ACTIVATE volume:10
    - playsound <player> sound:BLOCK_BEACON_POWER_SELECT volume:10
    - choose <[portal]>:
      - case return:
        - flag player gielinor.minigames.castle_wars.team:!
        - title title:<&chr[0004].font[gielinor:scene]> fade_in:5t stay:0s fade_out:1s
        - wait 5t
        - equip <player> head:air chest:air
        - teleport <player> <location[897,76.0625,1828,15,90,Gielinor]>
        - stop
      - case red blue:
        - define team <[portal]>
      - case green:
        - define reds <server.online_players_flagged[gielinor.minigames.castle_wars.team.red].size>
        - define blues <server.online_players_flagged[gielinor.minigames.castle_wars.team.blue].size>
        - if <[reds]> > <[blues]>:
          - define team blue
        - else if <[reds]> < <[blues]>:
          - define team red
        - else:
          - define team <list[red|blue].random>

    - title title:<&chr[0004].font[gielinor:scene]> fade_in:5t stay:0s fade_out:1s
    - wait 5t
    - teleport <yaml[minigames].read[castle_wars.queue_room.spawn_areas].blocks.random>

    - flag player gielinor.minigames.castle_wars.in_queue
    - flag player gielinor.minigames.castle_wars.team.<[team]>
    - equip head:castle_wars_<[team]>_helmet
    - equip chest:castle_wars_<[team]>_cloak

  player_enter:
    - if <server.has_flag[gielinor.play_effects.castle_wars.hub]>:
      - stop
    - flag server gielinor.play_effects.castle_wars.hub
    - while <cuboid[castle_wars_hub].players.size> > 0:
      - foreach <list[red|green|blue]> as:team:
        - run castle_wars_portal_particles def:<[team]>
      - wait 3s
    - flag server gielinor.play_effects.castle_wars.hub:!

  player_exit:
    - flag player gielinor.minigames.castle_wars.in_queue:!

    - if <server.online_players_flagged[gielinor.minigames.castle_wars.in_queue].is_empty>:
      - flag server gielinor.minigames.castle_wars.queue:!
      - if <server.current_bossbars.contains_any[castle_wars_queue_red|castle_wars_queue_blue]>:
        - bossbar remove castle_wars_queue_red
        - bossbar remove castle_wars_queue_blue
    - else:
      - if <server.current_bossbars.contains_any[castle_wars_queue_red|castle_wars_queue_blue]>:
        - bossbar remove castle_wars_queue_red players:<player>
        - bossbar remove castle_wars_queue_blue players:<player>

  script:
    - while <server.has_flag[gielinor.minigames.castle_wars.queue]> && !<server.online_players_flagged[gielinor.minigames.castle_wars.in_queue].is_empty>:
      - define queued <server.online_players_flagged[gielinor.minigames.castle_wars.in_queue].size>
      - define reds <server.online_players_flagged[gielinor.minigames.castle_wars.team.red].size>
      - define blues <server.online_players_flagged[gielinor.minigames.castle_wars.team.blue].size>
      - define red_offset <[reds].sub[<[blues]>]>
      - define blue_offset <[blues].sub[<[reds]>]>

      #|- narrate "<&4><[reds]> <&3>| <&b><[blues]> <&b>|| <&4><[red_offset]> <&3>| <&b><[blue_offset]>"
      #|- define 1 <tern[<[queued].is[MORE].than[1]>].pass[<&a>TRUE].fail[<&4>FALSE]>
      #|- define 2 <tern[<list[0|1].contains[<[red_offset]>]>].pass[<&a>TRUE].fail[<&4>FALSE]>
      #|- define 3 <tern[<list[0|1].contains[<[blue_offset]>]>].pass[<&a>TRUE].fail[<&4>FALSE]>
      #|- narrate "<[1]> <&3>&& ( <[2]> <&3>|| <[3]> <&3>)

      - if <[queued]> > 1 && ( <list[0|1].contains[<[red_offset]>]> || <list[0|1].contains[<[blue_offset]>]> ):
        - if <server.has_flag[gielinor.minigames.castle_wars.start_time]>:
          - define time <duration[<server.flag[gielinor.minigames.castle_wars.start_time]>].sub[1s]>
        - else:
          - define time <duration[10m]>

        - if <[time].in_seconds> <= 0:
          - inject locally end

        - flag server gielinor.minigames.castle_wars.start_time:<[time]>
        - define bar <proc[castle_wars_queue_progress].context[<[time].formatted>]>
        - define progress <[time].in_seconds.div[600]>
        - bossbar update castle_wars_queue_red title:<[bar]> progress:<[progress]>
        - bossbar update castle_wars_queue_blue title:<[bar]> progress:<[progress]>
      - else:
        - if <server.has_flag[gielinor.minigames.castle_wars.start_time]>:
          - flag server gielinor.minigames.castle_wars.start_time:!
        - define bar <server.flag[gielinor.minigames.castle_wars.waiting_box]>
        - bossbar update castle_wars_queue_red progress:0 color:red title:<[bar]> players:<server.online_players_flagged[gielinor.minigames.castle_wars.in_queue].filter[has_flag[gielinor.minigames.castle_wars.team.red]]>
        - bossbar update castle_wars_queue_blue progress:0 color:blue title:<[bar]> players:<server.online_players_flagged[gielinor.minigames.castle_wars.in_queue].filter[has_flag[gielinor.minigames.castle_wars.team.blue]]>
      - wait 3t

  end:
    - bossbar remove castle_wars_queue_red
    - bossbar remove castle_wars_queue_blue
    - flag server gielinor.minigames.castle_wars.queue:!
    - flag server gielinor.minigames.castle_wars.start_time:!
    - flag server gielinor.minigames.castle_wars.players:!|:<server.online_players_flagged[gielinor.minigames.castle_wars.in_queue]>
    - foreach <server.online_players_flagged[gielinor.minigames.castle_wars.in_queue].random[999]> as:player:
      - flag <[player]> gielinor.minigames.castle_wars.in_queue:!
      - flag <[player]> gielinor.minigames.castle_wars.in_game

    - run castle_wars_start
    - while stop

castle_wars_start:
  type: task
  script:
    - announce "game has started"

    - title title:<&chr[0004].font[gielinor:scene]> fade_in:5t stay:0s fade_out:1s targets:<server.flag[gielinor.minigames.castle_wars.players]>
    - wait 5t
    - heal <server.flag[gielinor.minigames.castle_wars.players]>
    - foreach red|blue as:team:
      - flag server gielinor.minigames.castle_wars.score.<[team]>:0
      # @ spawn players
      - foreach <server.online_players_flagged[gielinor.minigames.castle_wars.team.<[team]>]> as:player:
        - define spawn_location <yaml[minigames].read[castle_wars.<[team]>_castle.respawn_room.respawn].blocks.random>
        - teleport <[player]> <[spawn_location]>
      #$- ~run castle_wars_cheat_prevention def:<[player]>

    # @ spawn flags
    - run castle_wars_flag def:<[team]>

    # @ spawn barriers
    - run castle_wars_barriers

    # @ start timer
    - run castle_wars_timer

castle_wars_timer:
  type: task
  script:
    - flag server gielinor.minigames.castle_wars.active_queue:<queue.id>
    - bossbar create castle_wars_timer
    - flag server gielinor.minigames.castle_wars.timer:<duration[5m]>

    - while <server.has_flag[gielinor.minigames.castle_wars.active_queue]>:
      - define time <duration[<server.flag[gielinor.minigames.castle_wars.timer]>].sub[1s]>
      - define mm <[time].in_seconds.div[60].round_down.pad_left[2].with[0]>
      - define ss <[time].in_seconds.sub[<[mm].mul[60]>].pad_left[2].with[0]>

      - flag server gielinor.minigames.castle_wars.timer:<[time]>

      - define background <&font[gielinor:minigames/castle_wars]><&chr[0001]><&chr[F801]><&chr[0002]>
    #^- define background <&f><&chr[0001].font[gielinor:banners]><proc[negative_spacing].context[1]><&chr[0002].font[gielinor:banners]>
      - define red <proc[negative_spacing].context[214]><&4><proc[spacing_fix_int].context[bar_01|<server.flag[gielinor.minigames.castle_wars.score.red]>]>
    #^- define timer "<proc[positive_spacing].context[68]><&color[#262626]><proc[spacing_fix_int].context[bar_02|<[mm]>]> : <proc[spacing_fix_int].context[bar_02|<[ss]>]>"
      - define timer "<&font[gielinor:minigames/castle_wars]><proc[positive_spacing].context[68]><&color[#262626]><proc[spacing_fix_int].context[bar_02|<[mm]>]> : <proc[spacing_fix_int].context[bar_02|<[ss]>]>"
      - define blue <proc[positive_spacing].context[67]><&color[#0000b3]><proc[spacing_fix_int].context[bar_01|<server.flag[gielinor.minigames.castle_wars.score.blue]>]>
      - define bar <[background]><[red]><[timer]><[blue]><proc[positive_spacing].context[30]>

      - bossbar update castle_wars_timer title:<[bar]> players:<server.online_players_flagged[gielinor.minigames.castle_wars.in_game]>
      - wait 1s
      - if <[time].in_seconds> <= 0:
        - flag server gielinor.minigames.castle_wars.active_queue:!

    - bossbar remove castle_wars_timer
    - run castle_wars_end

castle_wars_barriers:
  type: task
  script:
    - foreach red|blue as:team:
      - showfake barrier <yaml[minigames].read[castle_wars.<[team]>_castle.player_barrier]> players:<server.flag[gielinor.minigames.castle_wars.players]> duration:10m

castle_wars_end:
  type: task
  script:
    - define red_score <server.flag[gielinor.minigames.castle_wars.score.red]>
    - define blue_score <server.flag[gielinor.minigames.castle_wars.score.blue]>
    - if <[red_score]> > <[blue_score]>:
      - announce format:colorize_red "Red team wins!"
    - else if <[red_score]> > <[blue_score]>:
      - announce format:colorize_blue "Blue team wins!"
    - else:
      - announce format:colorize_green "Tie game!"
    - title title:<&chr[0004].font[gielinor:scene]> fade_in:5t stay:0s fade_out:1s targets:<server.flag[gielinor.minigames.castle_wars.players]>
    - wait 5t

    - foreach <server.players_flagged[gielinor.minigames.castle_wars.death_screen]> as:player:
      - if <[player].is_online>:
        - adjust <[player]> respawn
      - else:
        - adjust <[player]> location:<cuboid[Gielinor,895,76.06250,1826,899,76.06250,1830].blocks.random.with_yaw[<util.random.int[75].to[105]>].with_pitch[15]>
    - foreach <server.players_flagged[gielinor.minigames.castle_wars.flag_carrier]> as:player:
      - flag <[player]> gielinor.minigames.castle_wars.flag_carrier:!
    - foreach <server.flag[gielinor.minigames.castle_wars.players]> as:player:
      - flag <[player]> gielinor.minigames.castle_wars.in_game:!
      - flag <[player]> gielinor.minigames.castle_wars.team:!
      - equip <[player]> head:air chest:air
      - foreach castle_wars_barricade|castle_wars_bandage as:item:
        - if <[player].inventory.contains.scriptname[<[item]>]>:
          - take scriptname:<[item]> from:<[player].inventory> quantity:<[player].inventory.quantity.scriptname[<[item]>]>
      - teleport <[player]> <cuboid[Gielinor,895,76.06250,1826,899,76.06250,1830].blocks.random.with_yaw[<util.random.int[75].to[105]>].with_pitch[15]>

    - if <yaml[barricades].contains[base_entities]>:
      - remove <yaml[barricades].list_keys[base_entities].include[<yaml[barricades].list_keys[hitbox_entities]>]>

    - yaml id:barricades set hitbox_entities:!
    - yaml id:barricades set base_entities:!
    - yaml id:barricades set red_count:0
    - yaml id:barricades set blue_count:0

    - flag server gielinor.minigames.castle_wars.flag_captured:!
    - flag server gielinor.minigames.castle_wars.players:!
    - flag server gielinor.minigames.castle_wars.timer:!
    - flag server gielinor.minigames.castle_wars.score:!

castle_wars_flag:
  type: task
  definitions: team
  return:
    - define location <yaml[minigames].read[castle_wars.<[team]>_castle.flag.location]>
    - define cLoc <[location].center.below[1.5]>
    - define Density 8
    - repeat <element[650].div[<[Density]>]>:
      - define Radius <[value].power[1.1].div[90]>
      - define yOffset <[value].div[20]>
      - define ySpiral <[value].to_radians.mul[<[Density]>]>
      - playeffect at:<[cLoc].add[<location[<[Radius]>,<[yOffset]>,0].rotate_around_y[<[ySpiral]>]>]> effect:redstone special_data:1.2|<[team]> visibility:250 offset:0
      - playeffect at:<[cLoc].add[<location[-<[Radius]>,<[yOffset]>,0].rotate_around_y[<[ySpiral]>]>]> effect:redstone special_data:1.2|<[team]> visibility:250 offset:0
      - playeffect at:<[cLoc].add[<location[0,<[yOffset]>,-<[Radius]>].rotate_around_y[<[ySpiral]>]>]> effect:redstone special_data:1.2|<[team]> visibility:250 offset:0
      - playeffect at:<[cLoc].add[<location[0,<[yOffset]>,<[Radius]>].rotate_around_y[<[ySpiral]>]>]> effect:redstone special_data:1.2|<[team]> visibility:250 offset:0
      - if <[value].mod[15]> == 0:
        - playeffect at:<[cLoc].add[<location[0,<[yOffset]>,<[Radius].mul[2]>].rotate_around_y[<[ySpiral]>]>]> effect:crit visibility:250 offset:0.5 quantity:2
        - playeffect at:<[cLoc].add[<location[<[Radius].mul[-2]>,<[yOffset]>,0].rotate_around_y[<[ySpiral]>]>]> effect:crit visibility:250 offset:0.5 quantity:2
        - playeffect at:<[cLoc].add[<location[0,<[yOffset]>,<[Radius].mul[-2]>].rotate_around_y[<[ySpiral]>]>]> effect:crit visibility:250 offset:0.5 quantity:2
        - playeffect at:<[cLoc].add[<location[0,<[yOffset]>,<[Radius].mul[2]>].rotate_around_y[<[ySpiral]>]>]> effect:crit visibility:250 offset:0.5 quantity:2
        - playsound <[location]> ENTITY_PHANTOM_FLAP volume:2
        - wait 1t
    - run castle_wars_flag def:<[team]>

  script:
    - define location <yaml[minigames].read[castle_wars.<[team]>_castle.flag.location]>
    - define direction <yaml[minigames].read[castle_wars.<[team]>_castle.flag.direction]>
    - define patterns <yaml[minigames].read[castle_wars.<[team]>_castle.flag.patterns]>

    - modifyblock <[location]> <[team]>_banner[direction=<[direction]>]
    - adjust <[location]> patterns:<[patterns]>

castle_wars_portal_particles:
  type: task
  definitions: portal
  script:
    - define z_offset 1
    - define y_offset 0
    - Choose <[portal]>:
      - case red:
        - define color <color[<util.random.int[200].to[255]>,0,0]>
      - case green:
        - define color <color[0,<util.random.int[200].to[255]>,0]>
      - case blue:
        - define color <color[0,0,<util.random.int[200].to[255]>]>
      - case return:
        - define color <color[0,<util.random.int[200].to[255]>,0]>
    - define location <cuboid[castle_wars_portal_<[portal]>].center.below[1]>
    - playsound sound:block_beacon_ambient <[location]> volume:0.3
    - repeat 360 as:loop_index:
      - wait 2t
      - if <[loop_index].mod[50]> == 0:
        - define z_offset:+:0.15
        - define y_offset:+:0.1
      - define offset <location[0,<[y_offset]>,<[z_offset]>].rotate_around_y[<[loop_index].to_radians.mul[7.5]>]>
      - playeffect effect:redstone at:<[location].add[<[offset]>]> offset:0.0 special_data:1.5|<[color]> visibility:50

castle_wars_door_effects:
  type: task
  definitions: locations|color|location
  script:
    - playeffect effect:redstone at:<[locations]> offset:0.5 quantity:10 special_data:1|<[color]>
    - playeffect effect:fireworks_spark at:<[locations]> offset:0.25 quantity:2
    - playsound <[location]> sound:BLOCK_BEACON_power_select pitch:2 volume:0.25

castle_wars_flag_event:
  type: task
  definitions: team
  team_verification:
    - define op_team <context.location.cuboids.filter[note_name.is[!=].to[castle_wars]].first.after[castle_wars_].before[_flag]>
    - if <player.has_flag[gielinor.minigames.castle_wars.team.red]>:
      - define player_team red
      - define offset <location[0.3,-1.7,0.3,0,135,Gielinor]>
    - else:
      - define player_team blue
      - define offset <location[0.7,-1.7,0.7,0,135,Gielinor]>

  home_team_check:
    - if <[op_team]> == <[player_team]>:
      - if <player.has_flag[gielinor.minigames.castle_wars.flag_carrier]>:
        - flag player gielinor.minigames.castle_wars.flag_carrier:!
        - flag server gielinor.minigames.castle_wars.flag_captured.<[op_team]>:!
        - run castle_wars_score_event def:<[player_team]>
      - stop

  script:
    #@ Define Main Definitions
    - if !<player.has_flag[gielinor.minigames.castle_wars.in_game]> || <player.has_flag[gielinor.minigames.castle_wars.flag_carrier]> || <server.has_flag[gielinor.minigames.castle_wars.flag_captured.<[op_team]>]>:
      - stop
    - flag player gielinor.minigames.castle_wars.flag_carrier
    - flag server gielinor.minigames.castle_wars.flag_captured.<[op_team]>
    - define location <yaml[minigames].read[castle_wars.<[op_team]>_castle.flag.location]>
    - define op_team_flag <item[<[op_team]>_banner].with[patterns=<yaml[minigames].read[castle_wars.<[op_team]>_castle.flag.patterns]>]>

    #@ Adjust Player
    - modifyblock <[location]> air
    - spawn castle_wars_<[op_team]>_flag_entity <[location].add[<[offset]>].with_yaw[<[offset].yaw>]> save:flag_entity
    - define flag_entity <entry[flag_entity].spawned_entity>
    - repeat 10:
      - if <player.location.yaw.sub[<[flag_entity].location.yaw>]> > 180:
        - rotate <[flag_entity]> d:1t yaw:<[flag_entity].location.yaw.sub[<player.location.yaw>].div[10]>
      - else:
        - rotate <[flag_entity]> d:1t yaw:<player.location.yaw.sub[<[flag_entity].location.yaw>].div[10]>
      - define Step <[location].below.points_between[<player.location>].distance[<[location].below.points_between[<player.location>].distance[0.1].size.div[100]>].get[<[value]>]||Shortex>
      - if <[step]> == shortex:
        - repeat stop
      - playeffect at:<[flag_entity].location.above[1.8]> effect:redstone special_data:1.2|<[op_team]> visibility:250 offset:0.1 quantity:10
      - playeffect at:<[Step].above[3.5]> effect:redstone special_data:1.2|<[op_team]> visibility:250 offset:0.1 quantity:10

      - wait 1t
      - adjust <[flag_entity]> move:<[Step].sub[<[flag_entity].location>]>
    - equip <player> head:<[op_team_flag]>
    - wait 2t
    - remove <[flag_entity]>
    - actionbar "<proc[colorize].context[<player.name> Captured The <[op_team].to_titlecase> Flag!|<[player_team]>_bold]>" targets:<server.online_players_flagged[gielinor.minigames.castle_wars.team.<[player_team]>]>
    - actionbar "<proc[colorize].context[The <[player_team].to_titlecase> Team Captured Your Flag!|<[player_team]>_bold]>" targets:<server.online_players_flagged[gielinor.minigames.castle_wars.team.<[op_team]>]>
    - inject locally effect

  effect:
    - while <player.has_flag[gielinor.minigames.castle_wars.flag_carrier]> && <player.is_online> && <player.is_spawned>:
      - define Pitch <player.location.pitch.to_radians>
      - define Yaw <player.location.yaw.mul[-1].to_radians>
      - define ySpiral <[Loop_Index].to_radians.mul[8]>
      - define DirRotate <location[0,1.75,0].rotate_around_x[<[Pitch]>].rotate_around_y[<[Yaw]>]>

      - playeffect at:<player.eye_location.above[0.1].add[<[DirRotate]>].add[<location[0.25,0,0,world].rotate_around_y[<[ySpiral]>]>]> effect:redstone special_data:1.2|<[op_team]> visibility:250 offset:0.0 quantity:0
      - playeffect at:<player.eye_location.above[0.1].add[<[DirRotate]>].add[<location[-0.25,0,0,world].rotate_around_y[<[ySpiral]>]>]> effect:redstone special_data:1.2|<[op_team]> visibility:250 offset:0.0 quantity:0
      ##- playeffect offset:0.0 quantity:0 at:<player.location.above[3.25].add[<location[0.25,0,0,world].rotate_around_y[<[ySpiral]>]>]> effect:redstone special_data:1.2|<[op_team]> visibility:250
      ##- playeffect offset:0.0 quantity:0 at:<player.location.above[3.25].add[<location[-0.25,0,0,world].rotate_around_y[<[ySpiral]>]>]> effect:redstone special_data:1.2|<[op_team]> visibility:250

      - playeffect at:<player.location.above[17].add[<location[0.25,0,0,world].rotate_around_y[<[ySpiral]>]>]> effect:redstone special_data:1.2|<[op_team]> visibility:250 offset:0.0 quantity:0
      - playeffect at:<player.location.above[17].add[<location[-0.25,0,0,world].rotate_around_y[<[ySpiral]>]>]> effect:redstone special_data:1.2|<[op_team]> visibility:250 offset:0.0 quantity:0

      - wait 1t

    - if <player.has_flag[gielinor.minigames.castle_wars.in_game]>:
      - equip head:castle_wars_<[player_team]>_helmet
    - flag player gielinor.minigames.castle_wars.flag_carrier:!
    - flag server gielinor.minigames.castle_wars.flag_captured.<[op_team]>:!
    - run castle_wars_flag.return def:<[op_team]>

castle_wars_score_event:
  type: task
  definitions: team
  script:
    - title "subtitle:<proc[colorize].context[<[team].to_titlecase> Scored!|<[team]>]>" targets:<server.online_players_flagged[gielinor.minigames.castle_wars.in_game]>
    - flag server gielinor.minigames.castle_wars.score.<[team]>:+:1

castle_wars_player_death:
  type: task
  script:
      - flag player gielinor.minigames.castle_wars.death_screen
  message:
    - if <player.has_flag[gielinor.minigames.castle_wars.flag_carrier]>:
      - inject castle_wars_team_definitions
      - flag player gielinor.minigames.castle_wars.flag_carrier:!
      - flag server gielinor.minigames.castle_wars.flag_captured.<[op_team]>:!
      - actionbar "<proc[colorize].context[The <[op_team].to_titlecase> Flag Was Dropped!|<[team]>_bold]>" targets:<server.online_players_flagged[gielinor.minigames.castle_wars.in_game]>

    - if <context.damager||invalid> != invalid:
      - narrate format:colorize_red targets:<context.entity> "<context.damager.name> has killed you!"

castle_wars_player_respawn:
  type: task
  after_game:
    - flag player gielinor.minigames.castle_wars.death_screen:!
    - if <server.has_flag[gielinor.minigames.castle_wars.in_game]>:
      - stop
    - determine <cuboid[Gielinor,895,76.06250,1826,899,76.06250,1830].blocks.random.with_yaw[<util.random.int[75].to[105]>].with_pitch[15]>

  script:
    - title title:<&chr[0004].font[gielinor:scene]> fade_in:0s stay:0s fade_out:1s
    - if <player.has_flag[gielinor.minigames.castle_wars.team.red]>:
      - define team red
      - define op_team blue
    - else:
      - define team blue
      - define op_team red

    - equip head:castle_wars_<[team]>_helmet chest:castle_wars_<[team]>_cloak
    - define spawn_location <yaml[minigames].read[castle_wars.<[team]>_castle.respawn_room.respawn].blocks.random>
    - determine <[spawn_location]>

castle_wars_explosive_potion:
  type: item
  material: potion
  display name: <proc[colorize].context[Explosive Potion|orange]>
  lore:
    - <&color[#C1F2F7]>I can use this to destroy rockslides and barricades.
  mechanisms:
    color: orange
    hides: all

castle_wars_red_helmet:
  type: item
  material: leather_helmet
  display name: <proc[colorize].context[Red Team Helmet|red]>
  lore:
    - <&color[#C1F2F7]>The colors of Zamorak.
  enchantments:
    - BINDING_CURSE:1
  mechanisms:
    color: red
    hides: hide_all
    unbreakable: true

castle_wars_blue_helmet:
  type: item
  material: leather_helmet
  display name: <proc[colorize].context[Blue Team Helmet|blue]>
  lore:
    - <&color[#C1F2F7]>The colors of Saradomin.
  enchantments:
    - BINDING_CURSE:1
  mechanisms:
    color: blue
    hides: hide_all
    unbreakable: true

castle_wars_red_cloak:
  type: item
  material: elytra
  display name: <proc[colorize].context[Red Team Cloak|red]>
  lore:
    - <&color[#C1F2F7]>The colors of Zamorak.
  enchantments:
    - BINDING_CURSE:1
  mechanisms:
    hides: hide_all
    unbreakable: true
    raw_nbt: <map.with[cloak].as[string:red]>

castle_wars_blue_cloak:
  type: item
  material: elytra
  display name: <proc[colorize].context[Blue Team Cloak|blue]>
  lore:
    - <&color[#C1F2F7]>The colors of Saradomin.
  enchantments:
    - BINDING_CURSE:1
  mechanisms:
    hides: hide_all
    unbreakable: true
    raw_nbt: <map.with[cloak].as[string:blue]>

castle_wars_bandage:
  type: item
  material: paper
  display name: <&f>Bandage
  lore:
    # % advanced tooltip
    - <&r><&f><&chr[9951]><proc[negative_spacing].context[9]><&chr[9950]><&r><&color[#cef7c0]> +10% Health
    - <&color[#C1F2F7]>Use this on yourself or
    - <&color[#C1F2F7]>another player for health.
    # % A box of bandages for healing.
  mechanisms:
    hides: hide_all
    nbt: uniquifier/<util.random.uuid>
    custom_model_data: 1300

castle_wars_bandage_task:
  type: task
  script:
    - if <player.has_flag[gielinor.minigames.castle_wars.bandage_cooldown]>:
      - stop

  table_grab:
    - if !<context.entity.framed_item.has_script> || <context.entity.framed_item.scriptname> != castle_wars_bandage:
      - stop
    - inject locally cooldown
    - drop castle_wars_bandage

  heal:
    - inject castle_wars_team_definitions
    - define target <player.precise_target||invalid>
    - if <[target]> != invalid && <[target].has_flag[gielinor.minigames.castle_wars.team.<[team]>]>:
      - if <[target].health> < <[target].health_max>:
        - inject locally cooldown
        - heal <[target]> <[target].health_max.div[10].round>
        - take scriptname:castle_wars_bandage
        - narrate targets:<[target]> format:colorize_green "<player.name> healed you!"
        - narrate format:colorize_green "You heal <[target].name> for some health."
        - stop

    - if <player.health> < <player.health_max>:
        - inject locally cooldown
        - heal <player.health_max.div[10].round>
        - take scriptname:castle_wars_bandage
        - narrate format:colorize_green "You recover some health."

  cooldown:
    - itemcooldown paper duration:15t
    - flag player gielinor.minigames.castle_wars.bandage_cooldown duration:15t

#@castle_wars_bandage_entity:
  #@type: entity
  #@debug: true
  #@entity_type: item_frame
  #@fixed: false
  #@rotation: up
  #@visible: false
  #@framed: stone|clockwise_45
  #@framed: castle_wars_bandage|<list[CLOCKWISE|CLOCKWISE_135|CLOCKWISE_45|COUNTER_CLOCKWISE|COUNTER_CLOCKWISE_45|FLIPPED|FLIPPED_45|NONE].random>

castle_wars_barricade:
  type: item
  material: paper
  display name: <&f>Barricade
  lore:
    # % advanced tooltip
    - <&r><&f><&chr[9951]><proc[negative_spacing].context[9]><&chr[9950]><&r><&color[#cef7c0]> 50 health
    - <&color[#C1F2F7]>Handy for hindering the
    - <&color[#C1F2F7]>enemy team's movement.
  mechanisms:
    hides: hide_all
    nbt: uniquifier/<util.random.uuid>
    custom_model_data: 1301

castle_wars_red_flag_entity:
  type: entity
  entity_type: armor_stand
  visible: false
  invulnerable: true
  gravity: false
  equipment: air|air|air|red_banner[patterns=YELLOW/FLOWER|YELLOW/STRIPE_CENTER|RED/TRIANGLE_TOP|YELLOW/CROSS|RED/SQUARE_TOP_LEFT|RED/SQUARE_TOP_RIGHT|RED/HALF_HORIZONTAL_MIRROR]

castle_wars_blue_flag_entity:
  type: entity
  entity_type: armor_stand
  visible: false
  invulnerable: true
  gravity: false
  equipment: air|air|air|blue_banner[patterns=WHITE/STRAIGHT_CROSS|BLUE/SQUARE_BOTTOM_LEFT|BLUE/SQUARE_BOTTOM_RIGHT|BLUE/SQUARE_TOP_LEFT|BLUE/SQUARE_TOP_RIGHT|WHITE/RHOMBUS_MIDDLE|BLUE/BORDER]

castle_wars_team:
  type: procedure
  definitions: player
  script:
    - if <[player].has_flag[gielinor.minigames.castle_wars.team.red]>:
      - determine red
    - else if <[player].has_flag[gielinor.minigames.castle_wars.team.blue]>:
      - determine blue
    - else:
      - determine none

castle_wars_team_definitions:
  type: task
  definitions: player
  script:
    - if <player.has_flag[gielinor.minigames.castle_wars.team.red]>:
      - define team red
      - define op_team blue
    - else:
      - define team blue
      - define op_team red

spacing_fix_int:
  type: procedure
  definitions: set|int
  script:
    - define offset 0
    - foreach <[int].to_list> as:key:
      - choose <[key]>:
        - case 1:
          - define offset:+:2
        - case 2 3 5 6 7 8 9 0:
          - define offset:+:0
        - case 4:
          - define offset:-:0
    
    - if <[offset]> < 0:
      - determine <proc[negative_spacing].context[<[offset]>]><[int].font[gielinor:<[set]>]>
    - else if <[offset]> > 0:
      - determine <proc[positive_spacing].context[<[offset]>]><[int].font[gielinor:<[set]>]>
    - else:
      - determine <[int].font[gielinor:<[set]>]>

castle_wars_waiting_bar_setup:
  type: task
  script:
    - define wpadding 4

    - define wleft <proc[negative_spacing].context[10]><&chr[0011]>
    - define wpad_left <&chr[F802]><&chr[0013]><element[<&chr[F802]><&chr[0013]>].repeat[<[wpadding].sub[2]>]><&chr[F802]><&chr[0015]>
    - define wcenter <element[<&chr[F802]><&chr[0012]>].repeat[<element[37].sub[<[wpadding].mul[2]>]>]>
    - define wpad_right <&chr[F802]><&chr[0016]><element[<&chr[F802]><&chr[0013]>].repeat[<[wpadding].sub[2]>]><&chr[F802]><&chr[0013]>
    - define wright <&chr[F802]><&chr[0014]><proc[negative_spacing].context[225]>

    - define wtext "Waiting for players to join the other team."

    - define wbox <&font[gielinor:minigames/castle_wars]><[wleft]><[wpad_left]><[wcenter]><[wpad_right]><[wright]>
    - define bar <&font[gielinor:minigames/castle_wars]><[wbox]><[wtext]>
  #^- bossbar id:test update progress:0 color:red title:<[bar]>
    - flag server gielinor.minigames.castle_wars.waiting_box:<[bar]>

castle_wars_queue_progress:
  type: procedure
  definitions: time
  script:
    - define wpadding 4

    - define wleft <proc[negative_spacing].context[10]><&chr[0011]>
    - define wpad_left <&chr[F802]><&chr[0013]><element[<&chr[F802]><&chr[0013]>].repeat[<[wpadding].sub[2]>]><&chr[F802]><&chr[0015]>
    - define wcenter <element[<&chr[F802]><&chr[0012]>].repeat[<element[37].sub[<[wpadding].mul[2]>]>]>
    - define wpad_right <&chr[F802]><&chr[0016]><element[<&chr[F802]><&chr[0013]>].repeat[<[wpadding].sub[2]>]><&chr[F802]><&chr[0013]>
    - define wright <&chr[F802]><&chr[0014]><proc[negative_spacing].context[225]>
    - define padding_fix <proc[positive_spacing].context[<map.with[12].as[30].with[18].as[27].with[28].as[22].with[34].as[19].get[<[time].text_width>]>]>

    - define wtext "Time until next game starts: <[time]>"

    - define wbox <[wleft]><[wpad_left]><[wcenter]><[wpad_right]><[wright]>
    - define bar <[wbox]><[padding_fix]><[wtext]><[padding_fix]>
    - determine <&font[gielinor:minigames/castle_wars]><[bar]>
    #- bossbar id:test2 update progress:0 color:red title:<[bar]>

castle_wars_cheat_prevention:
  type: task
  definitions: player
  script:
    - adjust <[player]> can_fly:false
    - adjust <[player]> gamemode:adventure

castle_wars_barricade_entity:
  type: task
  script:
    - if <player.has_flag[gielinor.minigames.castle_wars.barricade_cooldown]>:
      - stop

  table_grab:
    #^- if !<context.entity.framed_item.has_script> || <context.entity.framed_item.scriptname> != castle_wars_barricade:
    #^  - stop
    - if <player.location.find.entities[dropped_item].within[5].size> > 3:
      - stop
    - inject locally cooldown
    - drop castle_wars_barricade
    - playsound <player> sound:BLOCK_LADDER_PLACE volume:0.5

  place:
    # % check
    - define location <player.eye_location.precise_cursor_on[4]||invalid>
    - if <[location]> == invalid:
      - stop
    - inject castle_wars_team_definitions
    - if <yaml[barricades].read[<[team]>_count]> > 14:
      - narrate format:colorize_red "Your team already has the maximum number of barricades set!"
      - stop
    - define obstruction <list>
    - if !<player.cursor_on.material.is_solid> || <player.cursor_on.material.name.contains_any_text[door|wall|pressure_plate]>:
      - define center <player.cursor_on.center>
    - else:
      - define center <player.cursor_on.above.center>
    - if <[center].material.name> == structure_void || <[center].material.name.contains_any_text[door|wall|pressure_plate]>:
      - define obstruction:->:<[center]>
    - foreach 0.8,0,0|0.75,0,0.75|0,0,0.8|0,0,-0.8|-0.75,0,-0.75|-0.8,0,0|0.75,0,-0.75|-0.75,0,0.75|0,1,0|0,2,0|0,3,0 as:direction:
      - if ( !<[center].add[<[direction]>].material.name.contains_any_text[door|wall|pressure_plate]> && <[center].add[<[direction]>].material.is_solid> ) || <[center].add[<[direction]>].material.name> == structure_void:
        - define obstruction:->:<[center].add[<[direction]>]>
    - if !<[obstruction].is_empty>:
      - playeffect effect:barrier at:<[obstruction]> offset:0
      - stop
  # % cooldown
    - inject locally cooldown
    # $- take scriptname:castle_wars_barricade
    - playsound <player> sound:BLOCK_LADDER_STEP volume:0.5
    - spawn castle_wars_barricade_base_entity <[location]> save:base
    - define barricade_map <map.with[base].as[<entry[base].spawned_entity>]>

    - repeat 2:
      - mount castle_wars_barricade_hitbox_entity|castle_wars_barricade_hitbox_entity <entry[base].spawned_entity.location> save:entities
      - define hitbox_entities:|:<entry[entities].mounted_entities>
    - define barricade_map <[barricade_map].with[hitbox_entities].as[<[hitbox_entities]>]>
    - inject castle_wars_team_definitions
    - define barricade_map <[barricade_map].with[team].as[<[team]>].with[health].as[50]>
  # % save data
    - foreach <[hitbox_entities]> as:hitbox_entity:
      - yaml id:barricades set hitbox_entities.<[hitbox_entity]>:<entry[base].spawned_entity>
    - yaml id:barricades set base_entities.<entry[base].spawned_entity>.hitbox_entities:|:<[hitbox_entities]>
    - yaml id:barricades set base_entities.<entry[base].spawned_entity>.team:<[team]>
    - yaml id:barricades set base_entities.<entry[base].spawned_entity>.health:50
    - yaml id:barricades set <[team]>_count:+:1

  cooldown:
    - itemcooldown paper duration:15t
    - flag player gielinor.minigames.castle_wars.barricade_cooldown duration:15t

castle_wars_barricade_table_entity:
  type: entity
  entity_type: armor_stand
  equipment: air|air|air|castle_wars_barricade
  gravity: false
  custom:
    side-ways_armor_pose: 0,0.436,1.745

castle_wars_barricade_base_entity:
  type: entity
  entity_type: armor_stand
  gravity: false
  invulnerable: true
  custom_name_visible: false
  custom_name: <&chr[9950]><&color[#00ff00]><&chr[F821]><element[<&chr[F801]>■].repeat[15]>
  visible: false
  equipment: air|air|air|castle_wars_barricade
  armor_pose: head|0,0,0

castle_wars_barricade_hitbox_entity:
  type: entity
  entity_type: slime
  size: 3
  max_health: 100
  health: 100
  has_ai: false

castle_wars_barricade_damage:
  type: task
  definitions: base
  script:
    - define entity <yaml[barricades].read[hitbox_entities.<[base]>]>
    - if <server.has_flag[gielinor.minigames.castle_wars.barricade_damage_cooldown.<[entity]>]>:
      - stop
    - flag server gielinor.minigames.castle_wars.barricade_damage_cooldown.<[entity]> duration:15t

    - run locally animation def:<[entity]>
    - inject locally damage
    - if !<server.has_flag[gielinor.minigames.castle_wars.barricade_health_display.<[entity]>]>:
      - flag server gielinor.minigames.castle_wars.barricade_health_display.<[entity]> duration:5s
      - inject locally show_health

  animation:
    - playsound <[base].location> sound:BLOCK_LADDER_FALL volume:0.5
    - playeffect at:<[base].location.above[1.5]> effect:BLOCK_DUST special_data:oak_log offset:0.1 quantity:10
    - define influx <player.location.direction.vector>
    - repeat 2:
      - if !<server.entity_is_spawned[<[base]>]>:
        - stop
      - define rotation:+:3
      - adjust <[base]> armor_pose:head|<[influx].mul[<[rotation].to_radians>]>
      - wait 1t
    - repeat 3:
      - if !<server.entity_is_spawned[<[base]>]>:
        - stop
      - define rotation:-:4
      - adjust <[base]> armor_pose:head|<[influx].mul[<[rotation].to_radians>]>
      - wait 1t
    - repeat 2:
      - if !<server.entity_is_spawned[<[base]>]>:
        - stop
      - define rotation:+:3
      - adjust <[base]> armor_pose:head|<[influx].mul[<[rotation].to_radians>]>
      - wait 1t

  damage:
    - define damage 10
    - yaml id:barricades set base_entities.<[entity]>.health:-:<[damage]>
    - define health <yaml[barricades].read[base_entities.<[entity]>.health]>
    - if <[health]> <= 0:
      - inject castle_wars_barricade_damage.death

    - define green_int <[health].div[50].div[<element[1].div[15]>].round_up>
    - define red_int <element[15].sub[<[green_int]>]>
    - define bar <&color[#00ff00]><&chr[F821]><element[<&chr[F801]>■].repeat[<[green_int]>]><&color[#ff0000]><element[<&chr[F801]>■].repeat[<[red_int]>]>
    - adjust <[entity]> custom_name:<&chr[9950]><[bar]>

  show_health:
    - adjust <[entity]> custom_name_visible:true
    - waituntil rate:1s !<server.has_flag[gielinor.minigames.castle_wars.barricade_health_display.<[entity]>]> || !<server.entity_is_spawned[<[entity]>]>
    - if <server.entity_is_spawned[<[entity]>]>:
      - adjust <[entity]> custom_name_visible:false

  death:
    - define team <yaml[barricades].read[base_entities.<[entity]>.team]>
    - define entities <yaml[barricades].read[base_entities.<[entity]>.hitbox_entities]>
    - playeffect at:<[entity].location.above[0.6]>|<[entity].location.above[1.2]> effect:cloud offset:0.5 quantity:15

    - foreach <[entities]> as:old_entity:
      - yaml id:barricades set hitbox_entities.<[old_entity]>:!
    - yaml id:barricades set base_entities.<[entity]>:!
    - yaml id:barricades set <[team]>_count:-:1
    - remove <[entities].include[<[entity]>]>

    - stop

castle_wars_portal_door_particles:
  type: task
  script:
    - define portal_area <player.we_selection.blocks.parse[center].parse_tag[<[parse_value].left[0.1].points_between[<[parse_value].right[0.1]>].distance[0.1]>].combine>
    - repeat 10:
      - foreach <[portal_area]> as:area:
        - playeffect at:<[area]> effect:spell_instant quantity:1 offset:0.25,0.25,0.25
        - wait 1t

castle_wars_portal_door:
  type: task
  script:
    - define cuboid <context.location.cuboids.filter[note_name.is[!=].to[castle_wars]].first>
    - define area <[cuboid].note_name>
    - define color <[area].after[castle_wars_].before[_portal_door_]>

    - if !<player.has_flag[gielinor.minigames.castle_wars.team.<[color]>]>:
      - if !<player.has_flag[gielinor.message_rate_limit.castle_wars_wrong_respawn_door]>:
        - flag player gielinor.message_rate_limit.castle_wars_wrong_respawn_door duration:7s
        - narrate format:colorize_red "You can't go in there."
      - stop

    - if <player.has_flag[gielinor.minigames.castle_wars.flag_carrier]>:
      - if !<player.has_flag[gielinor.message_rate_limit.castle_wars_respawn_door_with_flag]>:
        - flag player gielinor.message_rate_limit.castle_wars_respawn_door_with_flag duration:7s
        - narrate format:colorize_red "You can't go in there with the flag."
      - stop
    
    - if <player.has_flag[gielinor.minigames.castle_wars.respawn_door_cooldown]>:
      - if !<player.has_flag[gielinor.message_rate_limit.castle_wars_respawn_door]>:
        - flag player gielinor.message_rate_limit.castle_wars_respawn_door duration:7s
        - narrate format:colorize_red "You must wait to use that again."
      - stop
    - flag player gielinor.minigames.castle_wars.respawn_door_cooldown duration:5s

    - define center <[cuboid].center>
    - define door_x <[center].x>
    - define door_y <[center].y>
    - define door_z <[center].z>
    - define player_x <player.location.x>
    - define player_y <player.location.y>
    - define player_z <player.location.z>

    - choose <[area].after_last[_]>:
      - case x:
        - if <[player_y]> < 82.19 && <[player_y]> >= 81 && <[player_z]> < <[door_z].add[0.69]> && <[player_z]> > <[door_z].sub[0.69]> && ( <[player_x]> < <[door_x].add[1]> || <[player_x]> > <[door_x].sub[1]> ):
          - run castle_wars_door_effects def:<list_single[<[cuboid].blocks>].include[<[color]>|<[center]>]>
          - define buffer <player.location.sub[<[center]>].normalize.x.mul[-2].min[0.225].max[-0.225].mul[2]>
          - foreach <player.location.points_between[<[center].with_y[<[player_y]>].add[<[buffer]>,0,0]>].distance[0.5].include[<[center].with_y[<[player_y]>].add[<[buffer]>,0,0]>]> as:location:
            - teleport <[location].with_pose[<player>]>
            - wait 1t

      - case y:
        - if <[player_y]> > 82 && <[player_y]> < 86.5 && <[player_z]> < <[door_z].add[0.75]> && <[player_z]> > <[door_z].sub[0.75]> && <[player_x]> < <[door_x].add[0.75]> && <[player_x]> > <[door_x].sub[0.75]>:
          - run castle_wars_door_effects def:<list_single[<[cuboid].blocks>].include[<[color]>|<[center]>]>
          - foreach <location[<player.location>].points_between[<[center].add[0,<player.location.sub[<[center]>].normalize.y.mul[-2].min[1].max[-1.5]>,0]>].distance[0.5]> as:location:
            - teleport <[location].with_pose[<player>]>
            - wait 1t

      - case z:
        - if <[player_y]> < 82.19 && <[player_y]> >= 81 && ( <[player_z]> < <[door_z].add[1]> || <[player_z]> > <[door_z].sub[1]> ) && <[player_x]> < <[door_x].add[0.69]> && <[player_x]> > <[door_x].sub[0.69]>:
          - run castle_wars_door_effects def:<list_single[<[cuboid].blocks>].include[<[color]>|<[center]>]>
          - define buffer <player.location.sub[<[center]>].normalize.z.mul[-2].min[0.225].max[-0.225].mul[2]>
          - foreach <player.location.points_between[<[center].with_y[<[player_y]>].add[<[buffer]>,0,0]>].distance[0.5].include[<[center].with_y[<[player_y]>].add[0,0,<[buffer]>]>]> as:location:
            - teleport <[location].with_pose[<player>]>
            - wait 1t

castle_wars_wooden_door:
  type: task
  axis_right:
    west: south
    north: west
    east: north
    south: east
  axis_left:
    west: north
    north: east
    east: south
    south: west
  script:
    - define cuboid <context.location.cuboids.filter[note_name.is[!=].to[castle_wars]].first>
    - define color <[cuboid].after[castle_wars_].before[_]>
    - define direction <[cuboid].after_last[_]>
    - foreach <[cuboid].blocks[spruce_door].filter[material.half.is[==].to[bottom]]> as:door:
      - switch <[door]>
      - define door_direction <[door].material.direction>
      - if <[door].material.switched>:
        - adjustblock <[door].above[2]> direction:<script.data_key[axis_<[door].material.hinge>.<[door_direction]>]>
      - else:
        - adjustblock <[door].above[2]> direction:<[door_direction]>

admin_tags:
  type: command
  name: cwadmin
  usage: /cwadmin
  description: none
  permission: admin
  tab completions:
    1: <list[force_queue|end_game|extend_game|remove_barricades].filter[starts_with[<context.raw_args.before_last[ ]>]]>
  script:
  - choose <context.args.first>:
    - case force_queue:
      - flag server gielinor.minigames.castle_wars.start_time:<duration[1s]>
    - case end_game:
      - flag server gielinor.minigames.castle_wars.timer:<duration[1s]>
    - case extend_game:
      - flag server gielinor.minigames.castle_wars.timer:<duration[<duration[<context.args.get[2]||5m>]||<duration[5m]>>]>
    - case remove_barricades:
      - if <yaml[barricades].contains[base_entities]>:
        - remove <yaml[barricades].list_keys[base_entities].include[<yaml[barricades].list_keys[hitbox_entities]>]>

      - yaml id:barricades set hitbox_entities:!
      - yaml id:barricades set base_entities:!
      - yaml id:barricades set red_count:0
      - yaml id:barricades set blue_count:0
