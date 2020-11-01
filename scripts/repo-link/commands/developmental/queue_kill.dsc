queuekill_command:
  type: command
  name: queuekill
  description: kills a named queue, or lists queues to kill.
  usage: /queuekill (queueid)
  permission: behr.essentials.queuekill
  debug: false
  tab complete:
    - if <context.args.size> == 0:
      - determine <queue.list.parse[id].exclude[<queue.id>]||>
    - else if <context.args.size> == 1 && !<context.raw_args.ends_with[<&sp>]>:
      - determine <queue.list.parse[id].exclude[<queue.id>].filter[starts_with[<context.args.last>]]||>
  script:
    - if <context.args.size> > 1:
      - inject command_syntax instantly

    - if <queue.list.size> == 1:
      - narrate "<&c>no active queues."
      - stop

    - if <context.args.size> == 0:
      - foreach <queue.list.exclude[<queue>]> as:queue:
        - define hover "<&c>click to kill queue<&4>:<&nl><&a><[queue].id><&nl><&e>script<&6>: <&a><queue.script><&nl><&e>file<&6>: <&a><queue.script.filename>"
        - define text "<&c>[<&4><&chr[2716]><&c>]<&e> <[queue].id>"
        - define command "queuekill <[queue].id>"
        - narrate <proc[msg_cmd].context[<[hover]>|<[text]>|<[command]>]>
    - else:
      - if !<queue.exists[<context.args.first>]>:
        - narrate "<&c>queue has ended or does not exist."
        - stop
      - narrate "<&e>killing queue<&6>: <&a><queue.list.exclude[<queue>].first>"
      - queue <queue[<context.args.first>]> stop
