admin_location:
  type: command
  name: location
  usage: /location
  description: teleports you across the maps
  debug: false
  permission: behr.essentials.location
  tab complete:
    - define commands <list[add|remove|teleport]>
    - if <context.args.is_empty>:
      - determine <[commands]>
    - else if <context.args.size> == 1 && "!<context.raw_args.ends_with[ ]>":
      - determine <[commands].filter[starts_with[<context.args.first>]]>

    - if <server.has_flag[behr.essentials.teleport.locations]>:
      - define locations <server.flag[behr.essentials.teleport.locations].as_map.keys>
      - if <context.args.size> == 1 && "<context.raw_args.ends_with[ ]>":
        - determine <[locations]>
      - else if <context.args.size> == 2 && "!<context.raw_args.ends_with[ ]>":
        - determine <[locations].filter[starts_with[<context.args.get[2]>]]>

  script:
    - if <context.args.is_empty>:
      - define locations <server.flag[behr.essentials.teleport.locations].as_map>
      - define lines <list>
      - foreach <[locations]> key:name as:location:
        - define hover "<&a>Click to teleport to:<n><[name]><&nl> at: <&e><[location].simple.before_last[,]>"
        - define command "location teleport <[name]>"
        - define text <&3><[name]>
        - define lines <[lines].include_single[<proc[msg_cmd].context[<[hover]>|<[text]>|<[command]>]>]>
      - define pages <[lines].sub_lists[10].parse[separated_by[<&nl>]]>
      - give <item[written_book].with[book=<map.with[pages].as[<[pages]>].with[title].as[locations].with[author].as[me]>]>
      - stop

    - if <context.args.size> != 2:
      - inject command_syntax

    - define arg2 <context.args.get[2]>
    - if <server.has_flag[behr.essentials.teleport.locations]>:
      - define locations <server.flag[behr.essentials.teleport.locations].as_map>
    - else:
      - define locations <map>

    - choose <context.args.first>:
      - case add:
        - if <[locations].contains[<[arg2]>]>:
          - define reason "Nothing interesting happens."
          - inject command_error
        - flag server behr.essentials.teleport.locations:<[locations].with[<[arg2]>].as[<player.location>]>
        - narrate "<proc[colorize].context[Added|green]> <proc[colorize].context[<&lb><[arg2].to_titlecase><&rb>|yellow]>"

      - case remove:
        - if !<[locations].contains[<[arg2]>]>:
          - define reason "Nothing interesting happens."
          - inject command_error
        - flag server behr.essentials.teleport.locations:<[locations].exclude[<[arg2]>]>
        - narrate "<proc[colorize].context[Removed|green]> <proc[colorize].context[<&lb><[arg2].to_titlecase><&rb>|yellow]>"

      - case teleport tp t:
        - if !<[locations].contains[<[arg2]>]>:
          - define reason "Nothing interesting happens."
          - inject command_error
        - teleport <[locations].get[<[arg2]>]>
        - narrate "<proc[colorize].context[teleported to|green]> <proc[colorize].context[<&lb><[arg2].to_titlecase><&rb>|yellow]>"

      - default:
        - inject command_syntax
