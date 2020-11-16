i:
  type: item
  material: stick

item:
  type: procedure
  definitions: name|quantity
  script:
    - if !<yaml[items].contains[items.<[name]>]>:
      - determine "stone[display_name=<&c>invalid item]"

    - define nbt <list>
    - define data <yaml[items].read[items.<[name]>]>

    # % Item Material and Model Properties
    - define item <item[i].with[material=<[data].get[material]>]>
    - if <[data].contains[custom_model_data]>:
      - define item <[item].with[custom_model_data=<[data].get[custom_model_data]>]>

    # % Item Display Name Property
    - define item "<[item].with[display_name=<[name].replace[_].with[ ].to_titlecase>]>"

    # % Item Examine Property
    - define lore <[data].get[examine]>

    # % Item Weight Property
    - if <[data].contains[weight]>:
      - define nbt <[nbt].include_single[weight/<[data].get[weight]>]>
    - else:
      - define nbt <[nbt].include_single[weight/0]>

    # % Item Notable Property
    - if <[data].contains[notable]>:
      - define nbt <[nbt].include_single[notable]>

    # % Item Value Properties
    - if <[data].contains[value]>:
      - foreach <[data].get[value]> key:currency:
        - define nbt <[nbt].include_single[value.<[currency]>/<[value]>]>

    - if <[quantity]||invalid> == invalid:
      - define quantity 1

    # % Item Quantity and Stack Properties
    - if <[data].contains[stackable]>:
      - define quantity_format <proc[item_quantity_format].context[<[quantity]>]>
      - define lore <list_single[<[quantity_format]>].include[<[Lore]>]>
      - define nbt <[nbt].include_single[stack/<[quantity]>]>
      - determine <[item].with[nbt=<[nbt]>;lore=<[lore]>]>
    - else:
      - if <[quantity]> == 1:
        - define nbt <[nbt].include_single[<[name]>/<util.random.uuid>]>
        - determine <[item].with[nbt=<[nbt]>;lore=<[lore]>]>
      - else:
        - define item_list <list>
        - define item <[item].with[lore=<[lore]>]>
        - repeat <[quantity]> as:loop_index:
          - define nbt <[nbt].include_single[<[name]>/<util.random.uuid>]>
          - define item <[item].with[nbt=<[nbt]>]>
          - define item_list <[item_list].include_single[<[item]>]>
        - determine <[item_list]>

item_quantity_format:
  type: procedure
  definitions: int
  script:
    - if <[int]> < 99999:
      - determine "<&7>Quantity<&8>: <&e><[int].format_number>"
    - else if <[int]> < 9999999:
      - determine "<&7>Quantity<&8>: <&f><[int].format_number.before_last[,]>K"
    - else:
      - determine "<&7>Quantity<&8>: <&a><[int].format_number.before_last[,].before_last[,]>M"
