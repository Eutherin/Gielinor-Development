gielinor_mining_handler:
  type: assignment
  debug: false
  actions:
    on click:
      # - ████████ [ Check for cooldown ] ████████
      - if <npc.has_flag[harvest_cooldown]>:
        - stop
      # % ████████ [ Definitions ] ████████
      - define ore_node_type  <npc.flag[type]>
      - define ore_type <npc.flag[type]>_ore
      - define ore_name <script.data_key[ore_handling_data.<[ore_type]>.display_name]>
      - define minimum_level <script.data_key[ore_handling_data.<[ore_type]>.minimum_level]>
      - define success_chance <script.data_key[ore_handling_data.<[ore_type]>.success_chance]>
      - define exp_amount <script.data_key[ore_handling_data.<[ore_type]>.exp_amount]>
      - define respawn_time <script.data_key[ore_handling_data.<[ore_type]>.respawn_time]>
      # $ ████████ [ ADD VALUE FOR SKILL MODIFIER ] ████████
      - define mining_level_bonus <element[0]>
      # $ ████████ [ ADD CHECK FOR CAPE ] ████████
      - if <player.flag[cape]> == sickass_mining_cape:
        - define cape_chance <element[5]>
      - else:
        - define cape_chance <element[0]>

      # % ████████ [ mining skill level check ] ████████
      - if <player.flag[skills_mining]> < <[minimum_level]>:
        - narrate format:colorize_red "You must have <[minimum_level]> mining in order to harvest <[ore_name]>."
        - stop
      # % ████████ [ roll for success. ] ████████
      # $ ████████ [ ADD CHECK FOR MODIFIERS ] ████████
      - define mining_result <util.random.int[0].to[100]>
      - if <[mining_result].add[<[mining_level_bonus]>]> >= success_chance:
        - give <proc[item].context[<[ore_type]>]>
        - run add_xp def:<[exp_amount]>|mining
        # % ████████ [ Chance for gloves/etc to not despawn. ] ████████
        # $ ████████ [ ADD SYNTAX FOR PLAYER EQUIPMENT CHECK ] ████████
        - if <player.flag[gloves]> == mining_gloves && <script.data_key[ore_handling_data.<[ore_type]>.mining_gloves_chance]> > 0:
          - define chance <util.random.int[0].to[100]>
          - if <[chance]> < <script.data_key[ore_handling_data.<[ore_type]>.mining_gloves_chance].sub[<[cape_chance]>]>:
            - stop
        - if <player.flag[gloves]> == expert_mining_gloves && <script.data_key[ore_handling_data.<[ore_type]>.expert_mining_gloves_chance]> > 0:
          - define chance <util.random.int[0].to[100]>
          - if <[chance]> < <script.data_key[ore_handling_data.<[ore_type]>.expert_mining_gloves_chance].sub[<[cape_chance]>]>:
            - stop
        - if <player.flag[gloves]> == superior_mining_gloves && <script.data_key[ore_handling_data.<[ore_type]>.superior_mining_gloves_chance]> > 0:
          - define chance <util.random.int[0].to[100]>
          - if <[chance]> < <script.data_key[ore_handling_data.<[ore_type]>.superior_mining_gloves_chance].sub[<[cape_chance]>]>:
            - stop
        # % ████████ [ Set cooldown, and equip models on timer. ] ████████
        - if <[respawn_time]> > 0:
          - flag <context.npc> harvest_cooldown d:<[respawn_time]>s
          - equip <context.npc> head:[<[ore_node_type]>_depleted]
          - wait <[respawn_time]>s
          - equip <context.npc> head:[<[ore_node_type]>_ready]


  ore_handling_data:
#-    template_ore:
#-        minimum_level:
#-        success_chance:
#-        exp_amount:
#-        respawn_time:
#-        mining_gloves_chance:
#-        superior_mining_gloves_chance:
#-        expert_mining_gloves_chance:
#-        display_name:
    chocolate_ore:
        minimum_level: 0
        success_chance: 
        exp_amount: 0
        respawn_time: 0
        display_name: Chocolate
    copper_ore:
        minimum_level: 1
        success_chance: 
        exp_amount: 17.5
        respawn_time: 2.4
        display_name: "Copper Ore"
    rock_ore:
        minimum_level: 1
        success_chance: 
        exp_amount: 1
        respawn_time: 5.4|11.4|23.4
        display_name: "Elemental Rocks"
    tin_ore:
        minimum_level: 1
        success_chance: 
        exp_amount: 17.5
        respawn_time: 2.4
        display_name: "Tin Ore"
    clay_ore:
        minimum_level: 1
        success_chance: 
        exp_amount: 5
        respawn_time: 1.2
        display_name: Clay
    rune_essence_ore:
        minimum_level: 1
        success_chance: 
        exp_amount: 5
        respawn_time: 0
        display_name: "Rune Essence"
    limestone_ore:
        minimum_level: 10
        success_chance: 
        exp_amount: 26.5
        respawn_time: 5.4
        display_name: Limestone
    blurite_ore:
        minimum_level: 10
        success_chance: 
        exp_amount: 17.5
        respawn_time: 25
        display_name: "Blurite Ore"
    iron_ore:
        minimum_level: 15
        success_chance: 
        exp_amount: 35
        respawn_time: 5.4
        display_name: "Iron Ore"
    daeyalt_ore:
        minimum_level: 20
        success_chance: 
        exp_amount: 17.5
        respawn_time: 28
        display_name: "Daeyalt Ore"
    silver_ore:
        minimum_level: 20
        success_chance: 
        exp_amount: 40
        respawn_time: 60
        mining_gloves_chance: 50
        expert_mining_gloves_chance: 50
        display_name: "Silver Ore"
    ash_ore:
        minimum_level: 22
        success_chance: 
        exp_amount: 10
        respawn_time: 30
        display_name: Ash
    coal_ore:
        minimum_level: 30
        success_chance: 
        exp_amount: 50
        respawn_time: 30
        mining_gloves_chance: 40
        expert_mining_gloves_chance: 40
        display_name: "Coal Ore"
    pay-dirt_ore:
        minimum_level: 30
        success_chance: 
        exp_amount: 60
        respawn_time: 60
        display_name: Pay-Dirt
    sandstone_ore:
        minimum_level: 35
        success_chance: 
        exp_amount: 30|40|50|60
        respawn_time: 5
        display_name: Sandstone
    gold_ore:
        minimum_level: 40
        success_chance: 
        exp_amount: 65
        respawn_time: 60
        mining_gloves_chance: 33
        expert_mining_gloves_chance: 34
        display_name: "Gold Ore"
    gem_ore:
        minimum_level: 40
        success_chance: 
        exp_amount: 65
        respawn_time: 59.4
        display_name: Gems
    sulphur_ore:
        minimum_level: 42
        success_chance: 
        exp_amount: 25
        respawn_time: 25.2
        display_name: Sulphur
    granite_ore:
        minimum_level: 45
        success_chance: 
        exp_amount: 50|60|75
        respawn_time: 5
        display_name: Granite
    mithril_ore:
        minimum_level: 55
        success_chance: 
        exp_amount: 80
        respawn_time: 12025
        expert_mining_gloves_chance: 25
        display_name: "Mithril Ore"
    lunar_ore:
        minimum_level: 60
        success_chance: 
        exp_amount: 0
        respawn_time: 0
        display_name: "Lunar Ore"
    daeyalt_shard_ore:
        minimum_level: 60
        success_chance: 
        exp_amount: 5
        respawn_time: 60
        display_name: "Daeyalt shards"
    lovakite_ore:
        minimum_level: 65
        success_chance: 
        exp_amount: 10
        respawn_time: 35
        display_name: "Lovakite Ore"
    adamantite_ore:
        minimum_level: 70
        success_chance: 
        exp_amount: 95
        respawn_time: 240
        mining_gloves_chance: 16
        expert_mining_gloves_chance: 17
        display_name: "Adamantite Ore"
    soft_clay_ore:
        minimum_level: 70
        success_chance: 
        exp_amount: 5
        respawn_time: 1.2
        mining_gloves_chance: 
        display_name: "Soft Clay"
    runite_ore:
        minimum_level: 85
        success_chance: 
        exp_amount: 125
        respawn_time: 720|360
        mining_gloves_chance: 12
        expert_mining_gloves_chance: 13
        display_name: "Runite Ore"
    amethyst_ore:
        minimum_level: 92
        success_chance: 
        exp_amount: 240
        respawn_time: 75
        expert_mining_gloves_chance: 25
        display_name: "Amethyst Ore"
