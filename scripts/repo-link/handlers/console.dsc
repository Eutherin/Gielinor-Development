console_handler:
  type: world
  debug: false
  events:
    on server start:
      - adjust system redirect_logging:true

    on reload scripts:
      - if <server.match_offline_player[behr_].is_online>:
        - if <context.had_error>:
          - narrate targets:<server.online_players_flagged[behr.essentials.debugging]> "<&c>Reload Error"
        - else:
          - narrate targets:<server.online_players_flagged[behr.essentials.debugging]> "<&a>Reloaded"
 
    on script generates error:
      - if "<context.message.contains_any_text[list_flags|{ braced } command format|'&dot' or '&cm']>":
        - determine cancelled
      - if <context.queue.contains[excommand_]||false>:
        - stop

      - if <server.match_offline_player[behr_].is_online>:
        - if <queue.exists[<context.queue.id||null>]>:
          - define hover0 "<&c>Click to kill queue<&4><&nl><context.queue.id>"
          - define text0 <&c>[<&4><&chr[2716]><&c>]<&r><&sp>
          - define command0 "queuekill <context.queue.id>"
          - define qk <proc[msg_cmd].context[<[hover0]>|<[text0]>|<[command0]>]>
        - define hover  "<&e>in <&c><context.queue.script.relative_filename||null><&e><&nl><context.message||null>"
        - define text "<&4>script error<&co> <&c><context.queue.script.name||null> <&e>on line<&6>: <&4>[<&c><context.line||unknown><&4>]"

        - narrate targets:<server.online_players_flagged[behr.essentials.debugging]> <[qk]||><proc[msg_hover].context[<[hover]>|<[text]>]>

    on server generates exception:
      - if <server.match_offline_player[behr_].is_online>:
        - if <context.queue.contains[excommand_]||false>:
          - stop
        - narrate targets:<server.online_players_flagged[behr.essentials.debugging]> "<&4>Server Generated Exception<&co> <&c><context.type>"

    on command:
      - if <context.source_type> != player:
        - define context <map.with[source_type].as[<context.source_type>]>
        - choose <context.source_type>:
          - case command_block:
            - define context <[context].with[command_block_location].as[<context.command_block_location>]>
          - case command_minecart:
            - define context <[context].with[command_minecart].as[<context.command_minecart>]>
      - else:
        - define context <map.with[source_type].as[<player>]>
        - define player_data <map.with[location].as[<player.location>]>
        - define player_data <[player_data].with[world].as[<player.world>]>
        - define player_data <[player_data].with[gamemode].as[<player.gamemode>]>
        - define context <[context].with[player_data].as[<[player_data]>]>

      - define context <[context].with[command].as[<context.command||invalid>]>
      - define context <[context].with[alias].as[<context.alias||invalid>]>
      - define context <[context].with[raw_args].as[<context.raw_args||invalid>]>
      - define context <[context].with[args].as[<context.args||invalid>]>
      - define context <[context].with[time].as[<util.time_now>]>
      - define file command_log/<util.time_now.format[yyyy-mm-dd]>.log
      - log type:none file:<[file]> <[context]>
