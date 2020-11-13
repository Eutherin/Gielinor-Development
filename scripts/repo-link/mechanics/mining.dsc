gielinor_mining_handler:
  type: world
  debug: false
  whitelist: chocolate|copper|elemental_rock|tin|clay|rune|limestone|blurite|iron|daeyalt|silver|ash|coal|pay-dirt|sandstone|gold|gem|sulphur|granite|mithril|lunar|daeyalt_essence|lovakite|adamantite|soft_clay|runite|amethyst
  events:
    on player clicks ARMORSTAND with:*_pickaxe:
      - if !<script[gielinor_mining_handler].data_key[whitelist].contains[<context.entity.name>]>:
        - stop
      - if <context.entity.has_flag[harvest_cooldown]>:
        - stop
    #definitions
      - define ore_node_type <context.entity.name>
      - define ore_type <context.entity.name>_ore
      - define ore_name <script[mining_data].data_key[ores.<[ore_type]>.display_name]>
      - define minimum_level <script[mining_data].data_key[ores.<[ore_type]>.minimum_level]>
      - define success_chance <script[mining_data].data_key[ores.<[ore_type]>.success_chance]>
      - define exp_amount <script[mining_data].data_key[ores.<[ore_type]>.exp_amount]>
      - define respawn_time <script[mining_data].data_key[ores.<[ore_type]>.respawn_time]>
      - define mining_gloves_proc_rate <script[mining_data].data_key[ores.<[ore_type]>.mining_gloves_chance].before[/]>
      - define expert_mining_gloves_proc_rate <script[mining_data].data_key[ores.<[ore_type]>.mining_gloves_chance].after[/]>
    #mining skill level check
      - if <player.flag[skills_mining]> < <[minimum_level]>:
        - narrate format:colorize_red "You must have <[minimum_level]> mining in order to harvest <[ore_name]>."
        - stop
    #roll for success.
    # - ADD PROPER STAT FOR PLAYER MODIFIERS
      - define mining_result <util.random.int[0].to[100]>
      - if <[mining_result].add[<player.mining_bonus>]> >= success_chance:
        - give <player> <[ore_type]>
        - run add_xp def:<[exp_amount]>|mining
        #Chance for gloves to not despawn
        # -ADD SYNTAX FOR PLAYER EQUIPMENT CHECK
        - if player.wearing mining_gloves && <[mining_gloves_proc_rate]> > 0:
          - define chance <util.random.int[0].to[100]>
          - if <[mining_gloves_proc_rate]> < <[chance]>:
            - stop
        - if player.wearing exepert_mining_gloves && <[expert_mining_gloves_proc_rate]> > 0:
          - define chance <util.random.int[0].to[100]>
          - if <[expert_mining_gloves_proc_rate]> < <[chance]>:
            - stop
        - flag <context.entity> harvest_cooldown d:<[respawn_time]>s
        - equip <context.entity> head:[<[ore_node]>_depleted]
        - wait <[respawn_time]>s
        - equip <context.entity> head:[<[ore_node]>_ready]

mining_data:
  type: data
  ores:
#    template_ore:
#        minimum_level:
#        success_chance:
#        exp_amount:
#        respawn_time:
#        mining gloves chance:
#        display_name:
    chocolate_ore:
        minimum_level: 0
        success_chance: 
        exp_amount: 0
        respawn_time: 0
        mining gloves chance: 
        display_name: Chocolate
    copper_ore:
        minimum_level: 1
        success_chance: 
        exp_amount: 17.5
        respawn_time: 2.4
        mining gloves chance: 
        display_name: "Copper Ore"
    elemental_rock_ore:
        minimum_level: 1
        success_chance: 
        exp_amount: 1
        respawn_time: 5.4|11.4|23.4
        mining gloves chance: 
        display_name: "Elemental Rocks"
    tin_ore:
        minimum_level: 1
        success_chance: 
        exp_amount: 17.5
        respawn_time: 2.4
        mining gloves chance: 
        display_name: "Tin Ore"
    clay_ore:
        minimum_level: 1
        success_chance: 
        exp_amount: 5
        respawn_time: 1.2
        mining gloves chance: 
        display_name: Clay
    rune_ore:
        minimum_level: 1
        success_chance: 
        exp_amount: 5
        respawn_time: 0
        mining gloves chance: 
        display_name: "Rune Essence"
    limestone_ore:
        minimum_level: 10
        success_chance: 
        exp_amount: 26.5
        respawn_time: 5.4
        mining gloves chance: 
        display_name: Limestone
    blurite_ore:
        minimum_level: 10
        success_chance: 
        exp_amount: 17.5
        respawn_time: 25
        mining gloves chance: 
        display_name: "Blurite Ore"
    iron_ore:
        minimum_level: 15
        success_chance: 
        exp_amount: 35
        respawn_time: 5.4
        mining gloves chance: 
        display_name: "Iron Ore"
    daeyalt_ore:
        minimum_level: 20
        success_chance: 
        exp_amount: 17.5
        respawn_time: 28
        mining gloves chance: 
        display_name: "Daeyalt Ore"
    silver_ore:
        minimum_level: 20
        success_chance: 
        exp_amount: 40
        respawn_time: 60
        mining gloves chance: 
        display_name: "Silver Ore"
    ash_ore:
        minimum_level: 22
        success_chance: 
        exp_amount: 10
        respawn_time: 30
        mining gloves chance: 
        display_name: Ash
    coal_ore:
        minimum_level: 30
        success_chance: 
        exp_amount: 50
        respawn_time: 30
        mining gloves chance: 
        display_name: "Coal Ore"
    pay-dirt_ore:
        minimum_level: 30
        success_chance: 
        exp_amount: 60
        respawn_time: 60
        mining gloves chance: 
        display_name: Pay-Dirt
    sandstone_ore:
        minimum_level: 35
        success_chance: 
        exp_amount: 30|40|50|60
        respawn_time: 5
        mining gloves chance: 
        display_name: Sandstone
    gold_ore:
        minimum_level: 40
        success_chance: 
        exp_amount: 65
        respawn_time: 60
        mining gloves chance: 
        display_name: "Gold Ore"
    gem_ore:
        minimum_level: 40
        success_chance: 
        exp_amount: 65
        respawn_time: 59.4
        mining gloves chance: 
        display_name: Gems
    sulphur_ore:
        minimum_level: 42
        success_chance: 
        exp_amount: 25
        respawn_time: 25.2
        mining gloves chance: 
        display_name: Sulphur
    granite_ore:
        minimum_level: 45
        success_chance: 
        exp_amount: 50|60|75
        respawn_time: 5
        mining gloves chance: 
        display_name: Granite
    mithril_ore:
        minimum_level: 55
        success_chance: 
        exp_amount: 80
        respawn_time: 120
        mining gloves chance: 
        display_name: "Mithril Ore"
    lunar_ore:
        minimum_level: 60
        success_chance: 
        exp_amount: 0
        respawn_time: 0
        mining gloves chance: 
        display_name: "Lunar Ore"
    daeyaltshard_ore:
        minimum_level: 60
        success_chance: 
        exp_amount: 5
        respawn_time: 60
        mining gloves chance: 
        display_name: "Daeyalt shards"
    lovakite_ore:
        minimum_level: 65
        success_chance: 
        exp_amount: 10
        respawn_time: 35
        mining gloves chance: 
        display_name: "Lovakite Ore"
    adamantite_ore:
        minimum_level: 70
        success_chance: 
        exp_amount: 95
        respawn_time: 240
        mining gloves chance: 
        display_name: "Adamantite Ore"
    softclay_ore:
        minimum_level: 70
        success_chance: 
        exp_amount: 5
        respawn_time: 1.2
        mining gloves chance: 
        display_name: "Soft Clay"
    runite_ore:
        minimum_level: 85
        success_chance: 
        exp_amount: 125
        respawn_time: 720|360
        mining gloves chance: 
        display_name: "Runite Ore"
    amethyst_ore:
        minimum_level: 92
        success_chance: 
        exp_amount: 240
        respawn_time: 75
        mining gloves chance: 
        display_name: "Amethyst Ore"
