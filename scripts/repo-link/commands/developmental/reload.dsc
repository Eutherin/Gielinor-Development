reload_command:
    type: command
    name: reload
    permission: behr.essentials.reload
    usage: /reload
    description: reloads
    aliases:
        - /r
    script:
        - reload

reload_handler:
  type: world
  events:
    on reload command:
      - determine passively fulfilled
      - reload
