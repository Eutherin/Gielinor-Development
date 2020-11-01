gielinor_handlers:
  type: world
  events:
    on entity starts gliding:
      - if <player.gamemode> != creative:
        - determine cancelled

    on player changes food level:
      - determine 20

    on player clicks block priority:10:
      - if <player.gamemode> != creative:
        - determine cancelled
