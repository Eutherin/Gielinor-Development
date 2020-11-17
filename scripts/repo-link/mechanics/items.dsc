i:
  type: item
  material: stick

item:
  type: procedure
  definitions: name|quantity
  script:
  # % Validate Item Name
    - if !<yaml[items].contains[items.<[name]>]>:
      - determine "stone[display_name=<&c>invalid item]"

  # % Define Base Definitions
    - define nbt <list_single[type/generic]>
    - define data <yaml[items].read[items.<[name]>]>

  # % Item Material and Model Properties
    - define item <item[i].with[material=<[data].get[material]>]>
    - if <[data].contains[custom_model_data]>:
      - define item <[item].with[custom_model_data=<[data].get[custom_model_data]>]>

  # % Item Display Name Property
    - define item "<[item].with[display_name=<&r><&f><[name].replace[_].with[ ].to_titlecase>]>"

  # % Item Examine Property
    - define lore <[data].get[examine].parse_tag[<&color[#C1F2F7]><[parse_value]>]>

  # % Item Weight Property
    - if <[data].contains[weight]>:
      - define nbt <[nbt].include_single[weight/<[data].get[weight]>]>
    - else:
      - define nbt <[nbt].include_single[weight/0]>

  # % Item Notable and Destroyable Properties
    - foreach notable|destroyable as:property:
      - if <[data].contains[<[Property]>]>:
        - define nbt <[nbt].include_single[<[Property]>/<[data].get[<[Property]>]>]>

  # % Item Value Properties
    - if <[data].contains[value]>:
      - foreach <[data].get[value]> key:currency:
        - define nbt <[nbt].include_single[value.<[currency]>/<[value]>]>

  # % Item Quantity and Stack Properties
    - if <[quantity]||invalid> == invalid:
      - define quantity 1

    - if <[data].contains[stackable]>:
      - define quantity_format <proc[item_quantity_format].context[<[quantity]>]>
      - define lore <list_single[<[quantity_format]>].include[<[Lore]>]>
      - define nbt <[nbt].include_single[stack/<[quantity]>]>
      - determine <[item].with[nbt=<[nbt]>;lore=<[lore]>]>

    - if <[quantity]> == 1:
      - define nbt <[nbt].include_single[<[name]>/<util.random.uuid>]>
      - determine <[item].with[nbt=<[nbt]>;lore=<[lore]>]>

    - define item_list <list>
    - define item <[item].with[lore=<[lore]>]>
    - repeat <[quantity]> as:loop_index:
      - define nbt <[nbt].include_single[<[name]>/<util.random.uuid>]>
      - define item <[item].with[nbt=<[nbt]>]>
      - define item_list <[item_list].include_single[<[item]>]>
    - determine <[item_list]>

equipment:
  type: procedure
  definitions: name|quantity
  script:
  # % Validate Item Name
    - if !<yaml[equipment].contains[items.<[name]>]>:
      - determine "stone[display_name=<&c>invalid item]"

  # % Define Base Definitions
    - define nbt <list_single[type/equipment]>
    - define data <yaml[equipment].read[items.<[name]>]>

  # % Item Material and Model Properties
    - define item <item[i].with[material=<[data].get[material]>]>
    - if <[data].contains[custom_model_data]>:
      - define item <[item].with[custom_model_data=<[data].get[custom_model_data]>]>

  # % Item Display Name Property
    - define item "<[item].with[display_name=<&r><&f><[name].replace[_].with[ ].to_titlecase>]>"

  # % Item Examine Property
    - define lore <[data].get[examine].parse_tag[<&color[#C1F2F7]><[parse_value]>]>

  # % Item Weight Property
    - if <[data].contains[weight]>:
      - define nbt <[nbt].include_single[weight/<[data].get[weight]>]>
    - else:
      - define nbt <[nbt].include_single[weight/0]>

  # % Item Notable, Destroyable, and Slot Properties
    - foreach notable|destroyable|slot as:property:
      - if <[data].contains[<[property]>]>:
        - define nbt <[nbt].include_single[<[property]>/<[data].get[<[property]>]>]>

  # % Item Value Properties
    - if <[data].contains[value]>:
      - foreach <[data].get[value]> key:currency:
        - define nbt <[nbt].include_single[value.<[currency]>/<[value]>]>

  # % Item Requirement Properties
    - if <[data].contains[requirements]>:
      - define requirements <[data].get[requirements]>
      - foreach <[requirements]> key:type as:requirement:
        - define nbt <[nbt].include_single[<[type]>/<[requirement]>]>

  # % Item Stats Properties
    - if <[data].contains[stats]>:
      - define stats <[data].get[stats]>
      - foreach <[data].get_subset[attack_bonus|defence_bonus|other_bonus]> key:modifier as:stat:
        - foreach <[stat]>:
          - define nbt <[nbt].include_single[stat.<[modifier]>.<[stat]>/<[value]>]>

      - if <[stats].contains[special_bonuses]>:
        - foreach <[stats].get[special_bonuses]> key:modifier:
          - define nbt <[nbt].include_single[<[modifier]>/<[value]>]>

      - foreach attack_speed|combat_options as:property:
        - if <[stats].contains[<[property]>]>:
          - define nbt <[nbt].include_single[<[property]>/<[stats].get[<[property]>]>]>

  # % Item Quantity and Stack Properties
    - if <[quantity]||invalid> == invalid:
      - define quantity 1

    - if <[data].contains[stackable]>:
      - define quantity_format <proc[item_quantity_format].context[<[quantity]>]>
      - define lore <list_single[<[quantity_format]>].include[<[Lore]>]>
      - define nbt <[nbt].include_single[stack/<[quantity]>]>
      - determine <[item].with[nbt=<[nbt]>;lore=<[lore]>]>

    - if <[quantity]> == 1:
      - define nbt <[nbt].include_single[<[name]>/<util.random.uuid>]>
      - determine <[item].with[nbt=<[nbt]>;lore=<[lore]>]>

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
