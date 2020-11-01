World_Handler:
  type: world
  events:
    on server prestart:
      - foreach Gielinor3|Dungeons as:World:
        - createworld <[World]>

      - foreach Gielinor_the_end as:World:
        - adjust <world[<[World]>]> Unload
