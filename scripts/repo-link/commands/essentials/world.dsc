world_command:
  type: command
  name: world
  debug: false
  description: teleports you to the specified world.
  admindescription: teleports you, or another player, to the specified world; additionally manages worlds.
  usage: /world (worldname)
  adminusage: /world (create/destroy/load/unload/teleport (player)) <&lt>worldname<&gt>
  permission: behr.essentials.world
  aliases:
    - spawn
  tab complete:
  # $ ██ [ change to whitelist server flag based on gui ] ██
    #- define blacklist <list[world_nether|world_the_end|runescape50px1|bandit-craft]>
    - define worlds <list[world|creative|skyblock]>
    - if !<player.groups.contains_any[coordinator|administrator|developer]> || <context.alias> == spawn:
      - if <context.args.is_empty>:
        - determine <[worlds]>
      - else if <context.args.size> == 1 && !<context.raw_args.ends_with[<&sp>]>:
        - determine <[worlds].filter[starts_with[<context.args.first>]]>

    - if <context.alias> != spawn:
      - define subcommands <list[create|destroy|load|unload|teleport]>
      - define loaded_worlds <server.worlds.parse[name]>
      - if <context.args.size> == 0:
        - determine <[subcommands].include[<[loaded_worlds]>]>

      - define validfolders <server.list_files[../../].exclude[<script[worldfilelist].data_key[blacklist]>]>
      - foreach <[validfolders]> as:folder:
        - if <server.list_files[../../<[folder]>].contains[level.dat]||false>:
          - define valid_worlds:->:<[folder]>
      - define valid_worlds <[valid_worlds].exclude[<[loaded_worlds]>]>

      - if <context.args.size> == 1 && !<context.raw_args.ends_with[<&sp>]>:
        - determine <[subcommands].include[<[loaded_worlds]>].filter[starts_with[<context.args.last>]]>
      - else if <context.args.size> == 1 && <context.raw_args.ends_with[<&sp>]>:
        - choose <context.args.first>:
          - case load:
            - determine <[valid_worlds]>
          - case destroy unload teleport tp:
            - determine <[loaded_worlds]>
          - default:
            - stop

      - if <context.args.size> == 2 && !<context.raw_args.ends_with[<&sp>]>:
        - choose <context.args.first>:
          - case load:
            - determine <[valid_worlds].filter[starts_with[<context.args.last>]]>
          - case destroy unload teleport tp:
            - determine <[loaded_worlds].filter[starts_with[<context.args.last>]]>
          - default:
            - stop

      - if <context.args.size> == 2 && <context.raw_args.ends_with[<&sp>]> && <context.args.first> == teleport:
        - determine <server.online_players.exclude[<player>].parse[name]>
      - if <context.args.size> == 3 && !<context.raw_args.ends_with[<&sp>]> && <context.args.first> == teleport:
        - determine <server.online_players.exclude[<player>].parse[name].filter[starts_with[<context.args.last>]]>

  script:
  # % ██ [  check args ] ██
    - if <context.args.is_empty>:
      - flag player behr.essentials.teleport.back:<map.with[location].as[<player.location>].with[world].as[<player.world.name>]>
      - teleport <player> <world[world].spawn_location>
      - stop

  # % ██ [  /world world ] ██
    - else if <context.args.size> == 1:
      - define world <context.args.first>

      # % ██ [  check if world is blacklisted ] ██
      - define blacklist <list[world_nether|world_the_end|runescape50px1]>
      - if <[blacklist].contains[<[world]>]>:
        - if !<player.groups.contains_any[coordinator|administrator|developer]>:
          - inject command_syntax
      
      # % ██ [  check if world is loaded ] ██
      - if !<server.worlds.parse[name].contains[<[world]>]>:
        - narrate "<proc[colorize].context[<&lb><[world]><&rb>|yellow]> <proc[colorize].context[is not currently loaded.|red]>"
        - if <player.groups.contains_any[coordinator|administrator|developer]>:
          - define hover "<proc[colorize].context[Click to create:|green]><&nl><proc[colorize].context[<&lb><[world]><&rb>|yellow]>"
          - define text <&a>[<&2><&l><&chr[2714]><&r><&a>]
          - define command "world create <[world]>"
          - define accept <proc[msg_cmd].context[<[hover]>|<[text]>|<[command]>]>
          - narrate "<&b>| <[accept]> <&b>| <proc[colorize].context[create world instead?:|green]> <proc[colorize].context[<&lb><[world]><&rb>|yellow]>"
        - stop

      # % ██ [  check if reasonable teleport ] ██
      - if <player.world.name> == <[world]>:
        - if <player.location.distance[<world[<[world]>].spawn_location>]> < 20:
          - define reason "You are already here."
          - inject command_error

    # % ██ [  check for creative ban ] ██
      - if <[world]> == creative && <player.has_flag[behr.moderation.creativeban]>:
        - define reason "This world is creative only and you are creative banned."
        - inject command_error

      # % ██ [  teleport player to the world ] ██
      - flag player behr.essentials.teleport.back:<map.with[location].as[<player.location>].with[world].as[<player.world.name>]>
      - teleport <player> <world[<[world]>].spawn_location>
      - narrate "<proc[colorize].context[you were teleported to world:|green]> <proc[colorize].context[<&lb><[world]><&rb>|yellow]>"
      - stop

    - else if !<player.groups.contains_any[coordinator|administrator|developer]>:
      - inject command_syntax

    - else if <context.args.size> < 2:
      - define reason "must specify a name."
      - inject command_error

    - else if <context.args.size> > 4:
      - inject command_syntax

    - define validfolders <server.list_files[../../].exclude[<script[worldfilelist].data_key[blacklist]>]>
    - foreach <[validfolders]> as:folder:
      - if <server.list_files[../../<[folder]>].contains[level.dat]||false>:
        - define valid_worlds:->:<[folder]>
    - define loaded_worlds <server.worlds.parse[name]>
    - define valid_worlds:!|:<[valid_worlds].exclude[<[loaded_worlds]>]>
    - define world <context.args.get[2]>
    
    - choose <context.args.first>:
      - case create:
        - if <context.args.size> != 2:
          - inject command_syntax

        - if <[loaded_worlds].contains[<[world]>]>:
          - narrate format:colorize_red "This world is loaded already."
          - stop

        - if <[valid_worlds].contains[<[world]>]>:
          - narrate format:colorize_red "World already exists."
          - inject locally loadworld

        - else if !<[world].matches_character_set[ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-]>:
          - define reason "World names should be alphanumerical."
          - inject command_error

        - else:
          - inject locally createworld

      - case destroy:
        - if <context.args.size> != 2:
          - inject command_syntax
          
        - if !<[loaded_worlds].contains[<[world]>]>:
          - define reason "World does not exist."
          - inject command_error

        - if <[world]> == world:
          - define reason "This world requires manual deletion."
          - inject command_error
          
        - define blacklist <list[runescape50px1|bandit-craft|gielinor3]>
        - if <[blacklist].contains[<[world]>]> && !<player.in_group[coordinator]>:
          - define reason "this world is blacklisted for deletion."
          - inject command_error

        - inject locally destroyworld

      - case load:
        - if <context.args.size> != 2:
          - inject command_syntax
          
        - if <[loaded_worlds].contains[<[world]>]>:
          - define reason "this world is loaded already."
          - inject command_error

        - if !<[valid_worlds].contains[<[world]>]>:
          - narrate format:colorize_red "world does not exist or not found."
          - inject locally createworld
          - stop

        - inject locally loadworld

      - case unload:
        - if <context.args.size> != 2:
          - inject command_syntax
          
        - if !<[loaded_worlds].contains[<[world]>]>:
          - define reason "this world is not loaded."
          - inject command_error

        - if <[world]> == world:
          - define reason "this world cannot be unloaded."
          - inject command_error
          
        - define blacklist <list[world_the_end|world_nether]>
        - if <[blacklist].contains[<[world]>]> && !<player.in_group[coordinator]>:
          - define reason "this world is blacklisted for unloading."
          - inject command_error
        
        - inject locally unloadworld

      - case teleport:
        - if <context.args.size> < 2:
          - inject command_syntax
        
        - if <context.args.size> == 3:
          - define user <context.args.get[3]>
          - inject player_verification
        - else:
          - define user <player>

        # % ██ [  check if world is loaded ] ██
        - if !<server.worlds.parse[name].contains[<[world]>]>:
          - narrate "<proc[colorize].context[<&lb><[world]><&rb>|yellow]> <proc[colorize].context[is not currently loaded.|red]>"
          - define hover "<proc[colorize].context[Click to create:|green]><&nl><proc[colorize].context[<&lb><[world]><&rb>|yellow]>"
          - define text <&a>[<&2><&l><&chr[2714]><&r><&a>]
          - define command "world create <[world]>"
          - define accept <proc[msg_cmd].context[<[hover]>|<[text]>|<[command]>]>
          - narrate "<&b>| <[accept]> <&b>| <proc[colorize].context[Create world instead?:|green]> <proc[colorize].context[<&lb><[world]><&rb>|yellow]>"
          - stop

        # % ██ [  check if reasonable teleport ] ██
        - if <[user].world.name> == <[world]>:
          - if <[user].location.distance[<world[<[world]>].spawn_location>]> < 20:
            - narrate format:colorize_red "player is already there."
            - stop

        # % ██ [  check for creative ban ] ██
        - if <[world]> == creative && <[user].has_flag[behr.moderation.creativeban]>:
          - if <[user]> != <player>:
            - narrate targets:<player> "Player is creative banned."
          - else:
            - narrate targets:<[user]> "This world is creative only and you are creative banned."
          - stop

        # % ██ [  teleport player to the world ] ██
        - flag <[user]> behr.essentials.teleport.back:<map.with[location].as[<player.location>].with[world].as[<player.world.name>]>
        - teleport <[user]> <world[<[world]>].spawn_location>
        - narrate targets:<[user]> "<proc[colorize].context[You were teleported to world:|green]> <proc[colorize].context[<&lb><[world]><&rb>|yellow]>"
        - if <[user]> != <player>:
          - narrate "<proc[colorize].context[Player was teleported to world:|green]> <proc[colorize].context[<&lb><[world]><&rb>|yellow]>"

      - default:
        - inject command_syntax
  loadworld:
    - if !<player.has_flag[behr.essentials.worldprompt.load]>:
      - flag player behr.essentials.worldprompt.load duration:10s
      - define hover "<proc[colorize].context[Click to load:|green]><&nl><proc[colorize].context[<&lb><[world]><&rb>|yellow]>"
      - define text <&a>[<&2><&l><&chr[2714]><&r><&a>]
      - define command "world load <[world]>"
      - define accept <proc[msg_cmd].context[<[hover]>|<[text]>|<[command]>]>
      - narrate "<&b>| <[accept]> <&b>| <proc[colorize].context[Load world?:|green]> <proc[colorize].context[<&lb><[world]><&rb>|yellow]>"
      - stop
    - flag player behr.essentials.worldprompt.load:!
    - narrate format:colorize_green "Loading world..."
    - createworld <[world]>
    - wait 1s
    - narrate "<&a>World loaded<&2>: <proc[colorize].context[<&lb><[world]><&rb>|yellow]>"
    - execute as_server "dynmap:dmap worldset <[world]> enabled:false"

  createworld:
    - if !<player.has_flag[behr.essentials.worldprompt.create]>:
      - flag player behr.essentials.worldprompt.create duration:10s
      - define hover "<proc[colorize].context[Click to create:|green]><&nl><proc[colorize].context[<&lb><[world]><&rb>|yellow]>"
      - define text <&a>[<&2><&l><&chr[2714]><&r><&a>]
      - define command "world create <[world]>"
      - define accept <proc[msg_cmd].context[<[hover]>|<[text]>|<[command]>]>
      - narrate "<&b>| <[accept]> <&b>| <proc[colorize].context[Create world?:|green]> <proc[colorize].context[<&lb><[world]><&rb>|yellow]>"
      - stop
    - flag player behr.essentials.worldprompt.create:!
    - narrate format:colorize_green "Creating world..."
    - createworld <[world]>
    - wait 1s
    - narrate "<&a>world created<&2>: <proc[colorize].context[<&lb><[world]><&rb>|yellow]>"
    - execute as_server "dynmap:dmap worldset <[world]> enabled:false"

  destroyworld:
    - if !<player.has_flag[behr.essentials.worldprompt.destroy0]>:
      - flag player behr.essentials.worldprompt.destroy0 duration:10s
      - define hover "<proc[colorize].context[Click to destroy:|red]><&nl><proc[colorize].context[<&lb><[world]><&rb>|yellow]>"
      - define text <&a>[<&2><&l><&chr[2714]><&r><&a>]
      - define command "world destroy <[world]>"
      - define accept <proc[msg_cmd].context[<[hover]>|<[text]>|<[command]>]>
      - narrate "<&b>| <[accept]> <&b>| <proc[colorize].context[Destroy world?:|green]> <proc[colorize].context[<&lb><[world]><&rb>|yellow]>"
      - stop
    - if !<player.has_flag[behr.essentials.worldprompt.destroy1]>:
      - flag player behr.essentials.worldprompt.destroy1 duration:10s
      - define hover "<proc[colorize].context[click to destroy:|red]><&nl><proc[colorize].context[<&lb><[world]><&rb>|yellow]>"
      - define text <&a>[<&2><&l><&chr[2714]><&r><&a>]
      - define command "world destroy <[world]>"
      - define accept <proc[msg_cmd].context[<[hover]>|<[text]>|<[command]>]>
      - narrate "<&b>| <[accept]> <&b>| <proc[colorize].context[Really Really destroy world?:|green]> <proc[colorize].context[<&lb><[world]><&rb>|yellow]>"
      - stop
    - flag player behr.essentials.worldprompt.destroy0:!
    - flag player behr.essentials.worldprompt.destroy1:!
    - narrate format:colorize_green "Destroying world..."
    - adjust <world[<[world]>]> destroy
    - wait 1s
    - narrate "<&c>World destroyed<&4>: <proc[colorize].context[<&lb><[world]><&rb>|yellow]>"

  unloadworld:
    - if !<player.has_flag[behr.essentials.worldprompt.unload]>:
      - flag player behr.essentials.worldprompt.unload duration:10s
      - define hover "<proc[colorize].context[Click to unload:|green]><&nl><proc[colorize].context[<&lb><[world]><&rb>|yellow]>"
      - define text <&a>[<&2><&l><&chr[2714]><&r><&a>]
      - define command "World unload <[world]>"
      - define accept <proc[msg_cmd].context[<[hover]>|<[text]>|<[command]>]>
      - narrate "<&b>| <[accept]> <&b>| <proc[colorize].context[Unload world?:|green]> <proc[colorize].context[<&lb><[world]><&rb>|yellow]>"
      - stop
    - flag player behr.essentials.worldprompt.destroy0:!
    - narrate format:colorize_green "unloading world..."
    - adjust <world[<[world]>]> unload
    - wait 1s
    - narrate "<&c>World unloaded<&4>: <proc[colorize].context[<&lb><[world]><&rb>|yellow]>"

worldfilelist:
  type: data
  worlds:
    - world
    - world_nether
    - world_the_end
    - hub
    - creative
    - runescape50px1

    - gielinor3
  blacklist:
    - banned-ips.json
    - banned-players.json
    - bukkit.yml
    - cache
    - commands.yml
    - crash-reports
    - data
    - eula.txt
    - help.yml
    - logs
    - ops.json
    - paper.yml
    - permissions.yml
    - plugins
    - server-icon.png
    - server.properties
    - spigot.yml
    - usercache.json
    - version_history.json
    - wepif.yml
    - whitelist.json
