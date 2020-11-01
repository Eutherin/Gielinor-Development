debug_command:
  type: command
  name: debug
  debug: false
  usage: /debug (server/player)
  description: enables or disables debugging for a player or the server.
  permission: behr.essentials.debugging
  tab complete:
    - define targets <list[server|player]>
    - if <context.args.is_empty>:
      - determine <[targets]>
    - else if <context.args.size> == 1 && "!<context.raw_args.ends_with[ ]>":
      - determine <[targets].filter[starts_with[<context.args.first>]]>
  script:
    - if <context.args.size> > 1:
      - inject command_syntax
    
    - choose <context.args.size>:
      - case 0:
        - if <player.has_flag[behr.essentials.debugging]>:
          - flag player behr.essentials.debugging:!
          - narrate "<&b>Debug disabled for <&a>Player<&b>."
        - else:
          - flag player behr.essentials.debugging
          - narrate "<&b>Debug enabled for <&a>Player<&b>."
      - case 1:
        - if <context.args.first> == server:
          - if <server.has_flag[behr.essentials.debugging]>:
            - flag server behr.essentials.debugging:!
            - narrate "<&b>Debug disabled for <&a>server<&b>."
          - else:
            - flag server behr.essentials.debugging
            - narrate "<&b>Debug enabled for <&a>server<&b>."
        - else if <context.args.first> == player:
          - if <player.has_flag[behr.essentials.debugging]>:
            - flag player behr.essentials.debugging:!
            - narrate "<&b>Debug disabled for <&a>Player<&b>."
          - else:
            - flag player behr.essentials.debugging
            - narrate "<&b>Debug enabled for <&a>Player<&b>."
        - else:
          - inject command_syntax
