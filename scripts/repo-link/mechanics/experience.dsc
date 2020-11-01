# - ███ [  when a player is directly connected to event:                  ] ███
# @ ███ |  - run add_xp def:<#>|<skill>                                   | ███
# @ ███ |   ex:run add_xp def:100|farming                                 | ███
# ! ███ [                                                                 ! ███
# - ███ [  when a player is not directly connected to the event:          ] ███
# @ ███ |  - run add_xp_nostring def:<#>|<skill>|<player>                 | ███
# @ ███ |   ex:run add_xp_nostring def:100|farming|<player[behr_riley]>   | ███

# @ ███ [ returns xp needed for next level                                ] ███
xp_calc:
  type: procedure
  debug: false
  definitions: lvl
  script:
    - define pow_term <[lvl].div[7]>
    - define mul_term <element[300].mul[<element[2].power[<[pow_term]>]>]>
    - determine <[lvl].add[<[mul_term]>].round_down.div[4].round_down>
    #- define line <element[0.5].mul[<[lvl].power[2]>].sub[<[lvl].mul[0.5]>].add[<element[2].power[<element[1].div[7]>].mul[300].mul[<element[2].power[<[lvl].div[7]>].sub[1].div[<element[2].power[<element[1].div[7]>].sub[1]>]>]>].round_down.div[4].round>



#@testcalc:
#@  type: task
#@  debug: false
#@  script:
#^    - define correct <list[83|91|102|112|124|138|151|168|185|204|226|249|274|304|335|369|408]>
#^    - repeat 17:
#^      - define newxp <proc[xp_calc2].context[<[value]>]>
#^      - if <[correct].get[<[value]>]> == <[newxp]>:
#^        - define xp "<&2>[<&a><&chr[2714]><&2>]<&a> <[newxp]>"
#^      - else:
#^        - define xp "<&4>[<&c><&chr[2716]><&4>]<&c> <[newxp]>"
#^      - narrate "<&e>level<&6>:<&a> <[value]> <&b> <&e>exp<&6>: <[xp]> <&b><[correct].get[<[value]>]>"

# % ███ [ grants the provided amount of xp to a player              ] ███
add_xp:
  type: task
  debug: false
  definitions: xp|skill
  script:
    - if !<player.has_flag[gielinor.skills.<[skill]>.experience]>:
      - flag player gielinor.skills.<[skill]>.experience:0
    - if !<player.has_flag[gielinor.skills.<[skill]>.experience_requirement]>:
      - flag player gielinor.skills.<[skill]>.experience_requirement:0
    - if !<player.has_flag[gielinor.skills.<[skill]>.level]>:
      - flag player gielinor.skills.<[skill]>.level:1
    
    - flag player gielinor.economy.coins:+:<[xp].round_up>
    - flag player gielinor.skills.<[skill]>.experience:+:<[xp]>
    - while <[xp]> > 0:
      - define xp_req <proc[xp_calc].context[<player.flag[gielinor.skills.<[skill]>.level]>]>
      - define to_add <[xp_req].sub[<player.flag[gielinor.skills.<[skill]>.experience_requirement]>]>
      - define xp <[xp].sub[<[to_add]>]>
      - if <[xp]> >= 0:
        - flag player gielinor.skills.<[skill]>.level:++
        - flag player gielinor.skills.<[skill]>.experience_requirement:0
        - if <player.flag[gielinor.skills.<[skill]>.level].mod[10]> == 0:
          - toast "<&e>Congratulations! your <&6><[skill]><&e> level is now <&6><player.flag[gielinor.skills.<[skill]>.level]>." icon:emerald frame:challenge
        - else:
          - toast "<&e>Congratulations! your <&6><[skill]><&e> level is now <&6><player.flag[gielinor.skills.<[skill]>.level]>." icon:emerald frame:task
        - narrate "Congratulations, you've just advanced a <&6><[skill]><&r> level. <&nl>your <&6><[skill]><&r> level is now <&6><player.flag[gielinor.skills.<[skill]>.level]><&f>."
      - else:
        - flag player gielinor.skills.<[skill]>.experience_requirement:+:<[xp].add[<[to_add]>]>

# % ███ [ grants the provided amount of xp to an unstrung player          ] ███
add_xp_nostring:
  type: task
  debug: false
  definitions: xp|skill|player
  script:
    - if !<[player].has_flag[gielinor.skills.<[skill]>.experience]>:
      - flag <[player]> gielinor.skills.<[skill]>.experience:<[xp]>
    - if !<[player].has_flag[gielinor.skills.<[skill]>.experience_requirement]>:
      - flag <[player]> gielinor.skills.<[skill]>.experience_requirement:0
    - if !<[player].has_flag[gielinor.skills.<[skill]>.level]>:
      - flag <[player]> gielinor.skills.<[skill]>.level:1
      
    - flag player gielinor.skills.<[skill]>.experience:+:<[xp]>
    - while <[xp]> > 0:
      - define xp_req <proc[xp_calc].context[<[player].flag[gielinor.skills.<[skill]>.level]>]>
      - define to_add <[xp_req].sub[<[player].flag[gielinor.skills.<[skill]>.experience_requirement]>]>
      - define xp <[xp].sub[<[to_add]>]>
      - if <[xp]> >= 0:
        - flag <[player]> gielinor.skills.<[skill]>.level:++
        - flag <[player]> gielinor.skills.<[skill]>.experience_requirement:0
        - toast targets:<[player]> "<&e>Congratulations! your <&6><[skill]><&e> level is now <&6><[player].flag[gielinor.skills.<[skill]>.level]>." icon:bow frame:challenge
        - narrate targets:<[player]> "Congratulations, you've just advanced a <&6><[skill]><&r> level! <&nl>your <&6><[skill]><&r> level is now <&6><[player].flag[gielinor.skills.<[skill]>.level]><&f>."
      - else:
        - flag <[player]> gielinor.skills.<[skill]>.experience_requirement:+:<[xp].add[<[to_add]>]>

experience_handler:
  type: world
  debug: false
  events:
    on player joins:
      - if !<player.has_flag[gielinor.skills.hitpoints.level]>:
        - flag player gielinor.skills.hitpoints.experience:1154
        - flag player gielinor.skills.hitpoints.level:10
