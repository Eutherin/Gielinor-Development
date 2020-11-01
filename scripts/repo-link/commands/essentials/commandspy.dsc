CommandSpy_Command:
  type: command
  name: commandspy
  debug: false
  description: Enables command spying on players
  permission: behr.essentials.commandspy
  aliases:
    - cspy
    - cmdspy
  usage: /commandspy (on/off)
  Activate:
    - if <player.has_flag[behr.essentials.commandlistening]>:
      - narrate "<proc[Colorize].context[Nothing interesting happens.|yellow]>"
    - else:
      - flag player behr.essentials.commandlistening
      - narrate "<proc[Colorize].context[CommandSpy Enabled.|green]>"
  Deactivate:
    - if !<player.has_flag[behr.essentials.commandlistening]>:
      - narrate "<proc[Colorize].context[Nothing interesting happens.|yellow]>"
    - else:
      - flag player behr.essentials.commandlistening:!
      - narrate "<proc[Colorize].context[CommandSpy Enabled.|green]>"
  script:
    - choose <context.args.first||invalid>:
      - case on:
        - inject locally Activate Instantly
      - case off:
        - inject locally Deactivate Instantly
      - case invalid:
        - if <player.has_flag[behr.essentials.commandlistening]>:
          - inject locally Deactivate Instantly
        - else:
          - inject locally Activate Instantly
      - case default:
        - inject Command_Syntax Instantly

command_listener:
  type: world
  debug: false
  events:
    on QE39XC command:
      - determine passively cancelled
      - if !<player.has_permission[behr.essentials.command.commandgrant]>:
        - define Hover "<&c>Permission Required<&4>: <&3>behr.essentials<&b>.<&3>command<&b>.<&3>commandgrant"
        - define Text "<&c>You do not have permission."
        - narrate <proc[msg_hover].context[<[Hover]>|<[Text]>]>
        - stop

      - flag <context.args.first||> behr.essentials.command.permission_provided:<&3>[<&b><player.display_name.strip_color><&3>] duration:1t
      - execute as_op player:<context.args.first||> "<context.args.get[2]||> <context.args.get[3]||> <context.args.get[4].to[99].space_separated||>"
      #- execute as_op player:<context.args.first> "<context.args.get[2]> <context.raw_args.replace[<context.args.get[<context.args.size>]>].with[]>"

    on command:
      - define Blacklist <list[WQGvt6LFz|QE39XC|b|bchat|dialogue|hpos1|hpos2|/hpos1|/hpos2]>
      - if <[Blacklist].contains[<context.command>]> || <context.server> || <player> == <server.match_player[behr_riley]||invalid>:
        - stop

      - foreach <server.online_players_flagged[behr.essentials.commandlistening]> as:Moderator:
        - if <[Moderator]> != <player>:
          - if <script[<context.command>_Command].data_key[permission]||invalid> != invalid:
            - define Permission <script[<context.command>_Command].data_key[permission]>
          - else:
            - define Permission Invalid
            
          - if !<player.has_permission[<[Permission]>]> && <[Permission]> != Invalid:
            - define Hover "<&c>Grant Permission<&4>: <&b>/<&3><context.command.to_lowercase> <context.raw_args>"
            - define Text "[<&8><player.display_name.strip_color><&7>]<&3>: <&b>/<&3><context.command.to_lowercase> <context.raw_args>"
            - define Command "QE39XC <player> <context.command.to_lowercase> <context.raw_args.replace[\].with[]||>"
            - if <player.has_flag[behr.essentials.command.permission_provided]>:
              - narrate targets:<[Moderator]> <player.flag[behr.essentials.command.permission_provided]><proc[msg_cmd].context[<list_single[<[Hover]>].include_single[<[Text]>].include_single[<[Command]>]>]>
            - else:
              - define Hover1 "<&c>Missing Permission:<&4> <&4><[Permission]>"
              - define Text1 <&c>[<&4><&chr[2716]><&c>]
              - narrate targets:<[Moderator]> <proc[msg_hover].context[<[Hover1]>|<[Text1]>]><&7><proc[msg_cmd].context[<list_single[<[Hover]>].include_single[<[Text]>].include_single[<[Command]>]>]>
          - else:
            - if <[Permission]> == Invalid:
              - define Hover "<&a>Permission<&2>: <&e>N<&6>/<&e>a"
            - else if <player.has_flag[behr.essentials.command.permission_provided]>:
              - define Hover "<&a>Granted Permission<&2>: <&b>/<&3><context.command.to_lowercase> <context.raw_args>"
            - else:
              - define Hover "<&a>Has Permission<&2>: <&b>/<&3><context.command.to_lowercase> <context.raw_args>"
            - define Text "<&7>[<&8><player.display_name.strip_color><&7>]<&3>: <&b>/<&3><context.command.to_lowercase> <context.raw_args>"
            #- define Command "QE39XC <player> <context.command.to_lowercase> <context.raw_args.replace[\].with[]||>"
            - narrate targets:<[Moderator]> <player.flag[behr.essentials.command.permission_provided]||><proc[msg_hover].context[<[Hover]>|<[Text]>]>
