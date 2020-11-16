behredit_wand:
  type: item
  material: netherite_axe
  display name: <&color[#C1F2F7]>B<&e>e<&color[#C1F2F7]>hrEdit Wand
  lore:
    - <proc[colorize].context[Left-Click:|green]> <&color[#C1F2F7]> Position <proc[colorize].context[<&lb>1<&rb>|yellow]>
    - <proc[colorize].context[Right-Click:|green]><&color[#C1F2F7]> Position <proc[colorize].context[<&lb>2<&rb>|yellow]>
    - <proc[colorize].context[F-Key:|green]><&color[#C1F2F7]> Position <proc[colorize].context[<&lb>C<&rb>|yellow]>
  mechanisms:
    hides: hide_all

behredit_wand_handler:
  type: world
  definitions: hand|location
  debug: false
  events:
    on player clicks block with:behredit_wand bukkit_priority:lowest:
      - if <player.has_flag[behr.essentials.behredit.plant_mode]>:
        - stop
      - determine passively cancelled
      - if <player.is_sneaking> && <context.click_type.contains_text[left]>:
        - inject behredit.click_clear
      - run behredit.select def:<context.click_type>|<context.location||<player.cursor_on||<player.eye_location>>>

    on player swaps items offhand:behredit_wand bukkit_priority:lowest:
      - determine passively cancelled
      - run behredit.select def:c|<player.cursor_on||<player.eye_location>>

    on player left clicks block with:behredit_wand flagged:behr.essentials.behredit.plant_mode priority:-1:
      - determine passively cancelled
      - if <player.cursor_on.material.is_solid>:
        - define location <player.cursor_on.above>
      - else:
        - define location <player.cursor_on>

      - schematic name:<player.uuid> paste <[location]> noair

    on player scrolls their hotbar flagged:behr.essentials.behredit.plant_mode:
      - ratelimit <player> 5t
      - determine passively cancelled
      - define group <player.flag[behr.essentials.behredit.tree_plant_selection]>
      - define index <player.flag[behr.essentials.behredit.tree_plan_index]>

      - define max_index <server.list_files[data/repo-link/tree_groups/<[group]>].size>

      - if <context.new_slot> == 1 && <context.previous_slot> == 9:
        - define index:+:17
      - else if <context.previous_slot> == 1 && <context.new_slot> == 9:
        - define index:-:17
      - else if <context.previous_slot> < <context.new_slot>:
        - define index:+:17
      - else:
        - define index:-:17

      - if <[index]> > <[max_index]>:
        - define index 1
      - else if <[index]> < 1:
        - define index <[max_index]>

      - flag player behr.essentials.behredit.tree_plan_index:<[index]>
      - actionbar "<proc[colorize].context[<&lb><[group]><&rb>|yellow]> <proc[colorize].context[tree index set to:|green]> <proc[colorize].context[<&lb><[index]><&rb>|yellow]>"


behredit_command:
  type: command
  debug: false
  name: behredit
  aliases:
    - b
  usage: /behredit
  description: Executes BehrEdit commands based on usage
  permission: behr.essentials.behredit
  tab:
    selection:
      usage: /b selection <&lt>mode<&gt>/list
      description: Sets the BehrEdit selection mode for the selection axe tool.
      tab:
        tree_selector:
          usage: /b selection tree_planting
          description: Used for selecting custom trees placed.
        cuboid:
          usage: /b selection cuboid
          description: Set points with left/right click for corner-to-corner cuboids, and F for center selection.
        expanding_cuboid:
          usage: /b selection expanding_cuboid
          description: Set points with left/right click for expanding cuboids, and F for center selection.
    clear:
      usage: /b clear
      description: Clears the active selection.
    monitor:
      usage: /b monitor
      description: Toggles the selection tool visual monitoring.
    hpos1:
      usage: /b hpos1
      description: Sets Position 1 to the cursor location.
    hpos2:
      usage: /b hpos2
      description: Sets Position 2 to the cursor location.
    hposc:
      usage: /b hposc
      description: Sets Position C to the cursor location.
    pos1:
      usage: /b pos1
      description: Sets Position 1 to your position.
      tab: <list_single[<player.location.simple.before_last[,]>]>
    pos2:
      usage: /b pos2
      description: Sets Position 2 to your position.
      tab: <list_single[<player.location.simple.before_last[,]>]>
    posc:
      usage: /b posc
      description: Sets Position C to your position.
      tab: <list_single[<player.location.simple.before_last[,]>]>
    tree:
      usage: /b tree <&lt>add/list/remove/select<&gt>
      tab:
        group:
          usage: /b tree group <&lt>add/list/remove<&gt>
          description: Manages tree groups within the tree repository.
          tab:
            add:
              usage: /b tree group add <&lt>name<&gt>
              description: Adds a new named tree group to the tree repository. Not required to add new categories.
            list:
              usage: /b tree group list
              description: Lists the current list of tree groups in the tree repository.
            remove:
              usage: /b tree group remove <&lt>name<&gt>
              description: Removes a named tree group from the tree repository.
              tab: <server.list_files[data/repo-link/tree_groups]||<list>>
        add:
          usage: /b tree add <&lt>group<&gt>
          description: adds tree group
          tab:  <server.list_files[data/repo-link/tree_groups]||<list>>
        remove:
          usage: /b tree remove <&lt>group<&gt>
          description: removes tree group
          tab: <server.list_files[data/repo-link/tree_groups]||<list>>
        list:
          usage: /b tree list
        select:
          usage: /b tree select <&lt>group<&gt>
          tab: <server.list_files[data/repo-link/tree_groups]||<list>>
        hard_reset:
          usage: /b tree hard_reset
          description: Resets the entire tree repository.
        plant_mode:
          usage: /b tree plant_mode <&lt>activate/deactivate/group<&gt>
          description: Controls various planting features
          tab:
            activate:
              usage: /b tree plant_mode activate
              description: Activates the planting mode.
            deactivate:
              usage: /b tree plant_mode deactivate
              description: Deactivates the planting mode.
            group:
              usage: /b tree plant_mode group <&lt>group<&gt>
              description: Selects the active tree group selection to plant.
              tab: <server.list_files[data/repo-link/tree_groups]||<list>>
    set:
      usage: /b set <&lt>materrial<&gt>
      description: Set a selected region to the selected material.
      tab: <server.material_types.filter[is_block]>
  tab complete:
    - if <context.args.is_empty>:
      - determine <script.list_keys[tab]>

    - if "!<context.raw_args.ends_with[ ]>":
      - define path tab<context.args.remove[last].parse_tag[.<[parse_value]>.tab].unseparated>
      - if <script.data_key[<[path]>]||invalid> != invalid:
        - if <script.data_key[<[path]>].type> == map:
          - determine <script.list_keys[<[path]>].filter[starts_with[<context.args.last>]]>
        - else:
          - determine <script.parsed_key[<[path]>].filter[starts_with[<context.args.last>]]>

    - else:
      - define path tab.<context.args.separated_by[.tab.]>
      - if <script.data_key[<[path]>.tab]||invalid> != invalid:
        - if <script.data_key[<[path]>.tab].type> == map:
          - determine <script.list_keys[<[path]>.tab]>
        - else:
          - determine <script.parsed_key[<[path]>.tab]>

  script:
    - if <context.args.is_empty>:
      - inject command_syntax

    - choose <context.args.first>:
      - case selection:
        - if <context.args.size> != 2:
          - inject command_syntax

        - if !<context.args.get[2].contains_any[cuboid|expanding_cuboid|tree_selector]>:
          - inject command_syntax

        - run behredit.selection_mode def:<context.args.get[2]>

      - case clear:
        - if <context.args.size> != 1:
          - inject command_syntax
        - run behredit.clear_selection
      
      - case monitor:
        - if <context.args.size> != 1:
          - inject command_syntax
        - run behredit.monitor.toggle
      
      - case hpos1 hpos2 hposc pos1 pos2 posc:
        - if <context.args.size> != 1:
          - inject command_syntax

        - define selection <context.args.first.after[pos]>
        - if <context.args.first.starts_with[h]>:
          - define location <context.location||<player.cursor_on||<player.eye_location>>>
        - else:
          - define location <player.location>

        - run behredit.select def:<[selection]>|<[location]>
      - case tree:
        - if <context.args.size> < 2:
          - inject command_syntax

        - choose <context.args.get[2]>:
          - case group:
            # % /b tree group <add <name> / list / remove <name> >
            - if <context.args.size> < 3:
              - inject command_syntax

            - choose <context.args.get[3]>:
              # % /b tree group add <name>
              - case add:
                - if <context.args.size> != 4:
                  - inject command_syntax
              
                - define group <context.args.get[4]>
                
                - if !<[group].matches_character_set[ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_]>:
                  - define reason "Invalid characters for group."
                  - inject command_error

                - if <yaml[tree_repository].contains[tree_groups.<[group]>]>:
                  - define reason "This group already exists within the tree repository."
                  - inject command_error

                - yaml id:tree_repository set tree_groups.<[group]>:<empty>
                - run save_yaml def:tree_repository
                - narrate "<proc[colorize].context[<&lb><[group]><&rb>|yellow]> <proc[colorize].context[was added to the tree repository.|green]>"

              # % /b tree group list
              - case list:
                - if <context.args.size> != 3:
                  - inject command_syntax
                
                - if !<yaml[tree_repository].contains[tree_groups]>:
                  - narrate format:colorize_yellow "There are no tree groups within the tree repository saved."
                  - stop
                
                - narrate format:colorize_yellow <server.list_files[data/repo-link/tree_groups].formatted>

              # % /b tree group remove <name>
              - case remove:
                - if <context.args.size> != 4:
                  - inject command_syntax

                - define group <context.args.get[4]>

                - if !<[group].matches_character_set[ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_]>:
                  - define reason "Invalid characters for group."
                  - inject command_error

                - if !<yaml[tree_repository].contains[tree_groups.<[group]>]>:
                  - define reason "This group does not exist within the repository."
                  - inject command_error

                - yaml id:tree_repository set tree_groups.<[group]>:!
                - run save_yaml def:tree_repository
                - narrate "<proc[colorize].context[<&lb><[group]><&rb>|yellow]> <proc[colorize].context[was removed from the tree repository.|green]>"

          # % /b tree add <group>
          - case add:
            - if <context.args.size> != 3:
              - narrate format:colorize_red "Specify a tree group."
              - stop
            - define group <context.args.get[3]>

            - if !<[group].matches_character_set[ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_]>:
              - define reason "Invalid characters for group."
              - inject command_error

            - if !<player.has_flag[behr.essentials.behredit.selection]>:
              - narrate format:colorize_red "Missing selection for tree to be saved."
              - stop

            - if !<player.has_flag[behr.essentials.behredit.posc]>:
              - narrate format:colorize_red "Missing center selection for tree to be centered to."
              - stop

            - if !<yaml[tree_repository].contains[tree_groups.<[group]>]>:
              - yaml id:tree_repository set tree_groups.<[group]>:<empty>
              - run save_yaml def:tree_repository
              - narrate "<proc[colorize].context[<&lb><[group]><&rb>|yellow]> <proc[colorize].context[was added to the tree repository.|green]>"

            - define center <player.flag[behr.essentials.behredit.posc].as_location>
            - define cuboid <player.flag[behr.essentials.behredit.selection].as_cuboid>

            - define uuid <util.random.duuid>
            - schematic create name:<[uuid]>_origin <[cuboid]> <[center]>
            - modifyblock <schematic[<[uuid]>_origin].cuboid[<[center]>]> air
            - foreach 0|90|180|270 as:angle:
              - foreach normal|flip_x|flip_z|flip_xz as:mode:
                - choose <[mode]>:
                  - case flip_x:
                    - schematic create name:<[uuid]> <[cuboid]> <[center]>
                    - schematic flip_x name:<[uuid]>
                    - schematic rotate name:<[uuid]> angle:<[angle]>
                  - case flip_z:
                    - schematic create name:<[uuid]> <[cuboid]> <[center]>
                    - schematic flip_z name:<[uuid]>
                    - schematic rotate name:<[uuid]> angle:<[angle]>
                  - case flip_xz:
                    - schematic create name:<[uuid]> <[cuboid]> <[center]>
                    - schematic flip_z name:<[uuid]>
                    - schematic flip_x name:<[uuid]>
                    - schematic rotate name:<[uuid]> angle:<[angle]>
                  - case normal:
                    - schematic create name:<[uuid]> <[cuboid]> <[center]>
                    - schematic rotate name:<[uuid]> angle:<[angle]>


                - schematic paste name:<[uuid]> <[center]> noair
                - define temp_cuboid <schematic[<[uuid]>].cuboid[<[center]>]>
                - inject behredit.tree_add
                - schematic save name:<[uuid]> filename:tree_groups/<[group]>/<[index]>
                - modifyblock <[temp_cuboid]> air
                - schematic unload name:<[uuid]>
                - schematic name:<[uuid]>_origin paste <[center]>
                - wait 3t
            - schematic unload name:<[uuid]>_origin

            - run save_yaml def:tree_repository
            - narrate "<proc[colorize].context[Tree added to repository under the|green]> <proc[colorize].context[<&lb><[group]><&rb>|yellow]> <proc[colorize].context[tree group.|green]>"

          - case hard_reset:
            - if !<player.has_flag[behr.message_rate_limit.behredit.tree_hard_reset]>:
              - flag player behr.message_rate_limit.behredit.tree_hard_reset duration:8s
              - narrate format:colorize_red "Perform hard reset on Tree Repository?"
              - stop
            - flag player behr.message_rate_limit.behredit.tree_hard_reset:!

            - run save_yaml def:tree_repository
            - narrate format:colorize_green "The Tree Repository was reset."
          # % /b tree plant_mode <activate/deactivate/group>
          - case plant_mode:
            - if <context.args.size> < 3:
              - inject command_syntax
            - choose <context.args.get[3]>:
              - case activate:
                - if <player.has_flag[behr.essentials.behredit.plant_mode]>:
                  - define reason "Planting mode is already enabled."
                  - inject command_error

                - flag player behr.essentials.behredit.plant_mode duration:10m
                - run behredit.plant_mode
              
              - case deactivate:
                - if !<player.has_flag[behr.essentials.behredit.plant_mode]>:
                  - define reason "Planting mode is not enabled."
                  - inject command_error
                
                - flag player behr.essentials.behredit.plant_mode:!
              
              # % /b tree plant_mode group <group>
              - case group:
                - if <context.args.size> != 4:
                  - inject command_syntax

                - define group <context.args.get[4]>
                
                - if !<server.list_files[data/repo-link/tree_groups].contains[<[group]>]>:
                  - define reason "This group does not exist in the tree repository."
                  - inject command_error
                
                - flag player behr.essentials.behredit.tree_plant_selection:<[group]>
                - narrate "<proc[colorize].context[Tree planting group set to:|green]> <proc[colorize].context[<[group]>|yellow]>"

              - case default:
                - inject command_syntax

          - default:
            - inject command_syntax
      # % /b set <material>
      - case set:
        - if <context.args.size> < 1:
          - inject command_syntax

        - if !<player.has_flag[behr.essentials.behredit.selection]>:
          - narrate format:colorize_red "Select a region first."
        
        - define material <context.args.get[2]>

        - if <server.material_types.filter[is_block].parse[name].contains[<[material]>]>

        - define cuboid <player.flag[behr.essentials.behredit.selection]>
        - modifyblock <[cuboid]> <[material]>

      - case wand:
        - give behredit_wand

      - default:
        - inject command_syntax
behredit:
  type: task
  debug: false
  version: 0.1
  color_map:
    1: 255,126,0
    2: 0,126,255
    c: 0,255,0
  script:
    - narrate "<proc[colorize].context[version: |green]><proc[colorize].context[<script.data_key[version]>|yellow]>"

  verify:
    selection_mode:
      - if !<player.has_flag[behr.essentials.behredit.selection_mode]>:
        - flag player behr.essentials.behredit.selection_mode:cuboid
    world_selection:
      - foreach 1|2|c as:node:
        - if <player.has_flag[behr.essentials.behredit.pos<[node]>]> && <player.flag[behr.essentials.behredit.pos<[node]>].as_location.world.name||invalid> != <player.world.name>:
          - inject locally clear_selection

  select:
    - define hand <[1]>
    - define location <[2]>

    - choose <[hand]>:
      - case left 1 left_click_air left_click_block:
        - define selection 1
      - case right 2 right_click_air right_click_block:
        - define selection 2
      - case center 3 c:
        - define selection C
      - default:
        - stop

    - define color <script.data_key[color_map].get[<[selection]>]>
    - define message_context "<list_single[<proc[colorize].context[Selection <[selection]>:|green]>]>"
    - inject locally verify.selection_mode
    - inject locally verify.world_selection

    - flag player behr.essentials.behredit.pos<[selection]>:<[location]>
    - define message_context <[message_context].include_single[<proc[colorize].context[<&lb><[location].simple.before_last[,]><&rb>|yellow]>]>

    - if <[selection]> != c:
      - if <player.has_flag[behr.essentials.behredit.pos1]> && <player.has_flag[behr.essentials.behredit.pos2]>:
        - choose <player.flag[behr.essentials.behredit.selection_mode]>:
          - case cuboid:
            - define cuboid <player.flag[behr.essentials.behredit.pos1].as_location.to_cuboid[<player.flag[behr.essentials.behredit.pos2].as_location>]>
            - flag player behr.essentials.behredit.selection:<[cuboid]>
          - case expanding_cuboid:
            - define cuboid <player.flag[behr.essentials.behredit.selection].as_cuboid.include[<[location]>]>
            - flag player behr.essentials.behredit.selection:<[cuboid]>
      - else:
        - define cuboid <[location].to_cuboid[<[location]>]>
        - flag player behr.essentials.behredit.selection:<[cuboid]>

      - define size <[cuboid].max.x.sub[<[cuboid].min.x>].add[1].mul[<[cuboid].max.y.sub[<[cuboid].min.y>].add[1]>].mul[<[cuboid].max.z.sub[<[cuboid].min.z>].add[1]>]>
      - define message_context <[message_context].include_single[<proc[colorize].context[<&lb><[size]><&rb>|yellow]>]>

    - run locally cube_selection def:<[color]>|<[location]>
    - if <player.has_flag[behr.essentials.behredit.selection]>:
      - run behredit.monitor.playeffect

    - narrate <[message_context].space_separated>

  selection_mode:
    - flag player behr.essentials.behredit.selection_mode:<[1]>
    - narrate "<proc[colorize].context[BehrEdit Selection Mode Set:|green]> <proc[colorize].context[<&lb><[1]><&rb>|yellow]>"

  clear_selection:
    - if <player.has_flag[behr.essentials.behredit.cube_particle_queue]> && <queue.exists[<player.flag[behr.essentials.behredit.cube_particle_queue]>]>:
      - queue <queue[<player.flag[behr.essentials.behredit.cube_particle_queue]>]> clear
    - flag player behr.essentials.behredit.cube_particle_queue:!
    - flag player behr.message_rate_limit.behredit.clear_selection:!
    - flag player behr.essentials.behredit.pos1:!
    - flag player behr.essentials.behredit.pos2:!
    - flag player behr.essentials.behredit.posc:!
    - flag player behr.essentials.behredit.selection:!
    - narrate format:colorize_green "Selection Cleared."

  cube_selection:
    - flag player behr.essentials.behredit.cube_particle_queue:<queue.id>
    - define color <[1]>
    - define location <[2]>
    - define subset <list>
    - foreach 1,0,0|0,1,0|0,0,1 as:direction:
      - define subset <[subset].include[<[location].points_between[<[location].add[<[direction]>]>].distance[0.1]>]>
      - define subset <[subset].include[<[location].add[1,1,1].points_between[<[location].add[1,1,1].sub[<[direction]>]>].distance[0.1]>]>
    - foreach 1,0,0|0,0,1 as:direction:
      - define subset <[subset].include[<[location].above.points_between[<[location].add[<[direction]>].above>].distance[0.1]>]>
      - define subset <[subset].include[<[location].add[1,0,1].points_between[<[location].add[<[direction]>]>].distance[0.1]>]>
      - define subset <[subset].include[<[location].add[<[direction]>].points_between[<[location].add[<[direction]>].above>].distance[0.1]>]>
    - repeat 10:
      - if !<player.has_flag[behr.essentials.behredit.selection]>:
        - stop
      - playeffect at:<[subset]> effect:redstone special_data:0.75|<[color]> offset:0 visibility:200
      - wait 3t

  monitor:
    toggle:
      - if <player.has_flag[behr.essentials.behredit.monitor]>:
        - flag player behr.essentials.behredit.monitor:!
        - narrate format:colorize_yellow "BehrEdit Monitor Disabled."
      - else:
        - flag player behr.essentials.behredit.monitor
        - narrate "BehrEdit Monitor Enabled." format:colorize_green
        - run locally monitor.display

    playeffect:
      - define cuboid <player.flag[behr.essentials.behredit.selection].as_cuboid>
      - define size <[cuboid].max.x.sub[<[cuboid].min.x>].add[1].mul[<[cuboid].max.y.sub[<[cuboid].min.y>].add[1]>].mul[<[cuboid].max.z.sub[<[cuboid].min.z>].add[1]>]>
      - if <[size]> < 500000:
        - playeffect at:<[cuboid].outline.parse[center]> effect:barrier offset:0 visibility:200
      - repeat 3:
        - if !<player.has_flag[behr.essentials.behredit.posc]>:
          - stop
        - run locally cube_selection def:0,255,0|<player.flag[behr.essentials.behredit.posc]>
        - wait 1s

    display:
      - while <player.is_online> && <player.has_flag[behr.essentials.behredit.monitor]>:
        - if !<player.has_flag[behr.essentials.behredit.selection]>:
          - actionbar "Monitor Active - No Selection" format:colorize_yellow
          - wait 5t
          - while next

        - if <player.flag[behr.essentials.behredit.selection].as_cuboid.world.name> != <player.world.name>:
          - actionbar "Monitor Active - Selection World" format:colorize_yellow
          - wait 5t
          - while next

        - run locally monitor.playeffect
        - actionbar "Monitor Active"  format:colorize_green
        - wait 3s

  click_clear:
    - if !<player.has_flag[behr.essentials.behredit.selection]>:
      - if !<player.has_flag[behr.message_rate_limit.behredit.clear_selection_repeat]>:
        - narrate format:colorize_yellow "Nothing interesting happens."
        - flag player behr.message_rate_limit.behredit.clear_selection_repeat duration:8s
      - stop
    - if !<player.has_flag[behr.message_rate_limit.behredit.clear_selection]>:
      - flag player behr.message_rate_limit.behredit.clear_selection duration:8s
      - narrate format:colorize_yellow "Clear Clipboard? Shift-Right-Click again to confirm"
      - stop
    - run behredit.clear_selection
    - stop
  tree_add:
    - define index <server.list_files[data/repo-link/tree_groups/<[group]>].size.add[1]||1>
    - define tree <map>
    - define blocks <list>

    - foreach <[temp_cuboid].blocks.filter[material.name.is[!=].to[air]]> as:block:
    #^- define block_data <map.with[location].as[<[block]>].with[material].as[<[block].material.name>].with[offset].as[<[center].sub[<[block]>].simple.before_last[,]>]>
      - define block_data <map.with[material].as[<[block].material.name>].with[offset].as[<[center].sub[<[block]>].simple.before_last[,]>]>
      - if <[block].material.has_multiple_faces>:
        - define block_data <[block_data].with[faces].as[<[block].material.faces>]>
      - if <[block].material.is_directional>:
        - define block_data <[block_data].with[direction].as[<[block].material.direction>]>
      - if <[block].material.is_bisected>:
        - define block_data <[block_data].with[half].as[<[block].material.half>]>
      - if <[block].material.name.contains_any[player_head|player_wall_head]>:
        - define block_data <[block_data].with[skull_skin].as[<[block].skull_skin.full>]>
      - define blocks <[blocks].include_single[<[block_data]>]>
    - define tree <[tree].with[blocks].as[<[blocks]>]>
    - playeffect at:<[temp_cuboid].shell.parse[center]> effect:flame offset:0

    #^- yaml id:tree_repository set tree_groups.<[group]>.<[index]>:<[tree]>
    - define yaml <[group]>_tree_<[index]>
    - yaml id:<[yaml]> create
    - yaml id:<[yaml]> set tree:<[tree]>
    - yaml id:<[yaml]> savefile:data/repo-link/tree_groups/<[group]>/<[index]>.yml
    - yaml id:<[yaml]> unload
    - announce to_console "<&a><[group]>.<[index]> <&e>saved"

  plant_mode:
    - if !<player.has_flag[behr.essentials.behredit.tree_plant_selection]>:
      - flag player behr.essentials.behredit.tree_plant_selection:Regular

    - define uuid <player.uuid>
    - define group <player.flag[behr.essentials.behredit.tree_plant_selection]>
    - define index <server.list_files[data/repo-link/tree_groups/<[group]>].random.before[.yml]>
    - flag player behr.essentials.behredit.tree_plan_index:<[index]>
    
    - schematic name:<[uuid]> load filename:tree_groups/<[group]>/<[index]>
    - while <player.has_flag[behr.essentials.behredit.plant_mode]> && <player.is_online>:
      - if <player.cursor_on||invalid> == invalid:
        - wait 1s
        - while next

      - if <[index]> != <player.flag[behr.essentials.behredit.tree_plan_index]> || <[group]> != <player.flag[behr.essentials.behredit.tree_plant_selection]>:
        - define index <player.flag[behr.essentials.behredit.tree_plan_index]>
        - define group <player.flag[behr.essentials.behredit.tree_plant_selection]>
        - schematic name:<[uuid]> unload
        - schematic name:<[uuid]> load filename:tree_groups/<[group]>/<[index]>

      - if <player.cursor_on.material.is_solid>:
        - if <player.cursor_on.above> == <[location]||invalid>:
          - schematic name:<[uuid]> paste fake_to:<player.world.players> fake_duration:1s <[location]> noair
          - wait 1s
          - while next
        - define location <player.cursor_on.above>
      - else:
        - if <player.cursor_on> == <[location]||invalid>:
          - schematic name:<[uuid]> paste fake_to:<player.world.players> fake_duration:1s <[location]> noair
          - wait 1s
          - while next
        - define location <player.cursor_on>
      
      - schematic name:<[uuid]> paste fake_to:<player.world.players> fake_duration:2t <[location]> noair
      - wait 2t
    - schematic name:<[uuid]> unload

  test_hold:
    - define tree <yaml[trees].read[tree_map.1]>
    - define blocks <[tree].get[blocks]>
    - repeat 300 as:i:
      - if <player.cursor_on||invalid> == invalid:
        - wait 1s
        - repeat next
      - if <player.cursor_on.material.is_solid>:
        - define location <player.cursor_on.above>
      - else:
        - define location <player.cursor_on>
      - define fake_displays <[blocks].parse_tag[<[location].sub[<[parse_value].get[offset]>]>]>
      - showfake lime_stained_glass <[fake_displays]> players:<player.world.players>
      - wait 1t
      - showfake cancel <[fake_displays]> players:<player.world.players>

yaml_fix:
  type: task
  script:
    - foreach <server.list_files[data/repo-link/tree_groups]> as:group:
      - if <yaml[tree_repository].list_keys[tree_groups.<[group]>]||invalid> == invalid:
        - foreach next
      - foreach <yaml[tree_repository].list_keys[tree_groups.<[group]>]> as:tree:
        - define yaml <[group]>_tree_<[tree]>
        - yaml id:<[yaml]> create
        - yaml id:<[yaml]> set tree:<yaml[tree_repository].read[tree_groups.<[group]>.<[tree]>]>
        - yaml id:<[yaml]> savefile:data/repo-link/tree_groups/<[group]>/<[tree]>.yml
        - yaml id:<[yaml]> unload
        - announce to_console "<&a><[group]>.<[tree]> <&e>saved"
        - yaml id:tree_repository set tree_groups.<[group]>.<[tree]>:!
        - waituntil rate:5t <server.recent_tps.first> > 16
        - wait 5t
