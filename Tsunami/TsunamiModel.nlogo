turtles-own [group speed cooperation initSpeed flight EP_knowledge chosenEP direction rescue_attempt initXcor initYcor newInformation my_EP]
patches-own [EvacuationPoint]
globals [saved cooperativeCitizen safeSpot time10 time30 time50 time80 time95 time_final survivors tempXcor tempYcor 
         meanXcor10 meanYcor10 meanXcor30 meanYcor30 meanXcor50 meanYcor50 meanXcor80 meanYcor80 meanXcor95 meanYcor95 meanXcor_final meanYcor_final
         stdXcor10  stdYcor10  stdXcor30  stdYcor30  stdXcor50  stdYcor50  stdXcor80  stdYcor80  stdXcor95  stdYcor95  stdXcor_final  stdYcor_final
         coo10 coo30 coo50 coo80 coo95 coo_final]

;;Environment setup
to mapa
  ca
  import-pcolors "map.png"
  crt citizens [set color black
          setxy random-xcor random-ycor
          set group random group_count
          set speed (random-normal 0.14 0.015) * 5 
          set initSpeed speed
          set EP_knowledge random-poisson av_EP_knowledge 
          set my_EP patch 100 -100
          set newInformation 0
          set direction heading
        ]
  
 
  ask turtles [
    move-to one-of patches with [pcolor = 67.4 and not any? other turtles-here] 
  ]
  
  ask n-of (count turtles * cooperative_citizens / 100) turtles [set cooperation true]
  
  let safePlace (list (patch -80 38) (patch -63 33) (patch -62 62) 
                              (patch -30 77) (patch -7 86) (patch 5 52)
                              (patch 17 45) (patch 30 51) (patch 60 57) (patch 78 20))
  
  foreach safePlace [ask ?[set pcolor white
                                   set EvacuationPoint 1]]
  
  set safeSpot patches with [EvacuationPoint = 1]
  
  ;;main street, business center where should be more people than in other places
  ask n-of (count turtles * 0.4) turtles [
     move-to one-of patches with [pcolor = 67.4 and distance patch -18 5 < 35 and not any? other turtles-here]
  ]
  
  ask turtles
       [set initXcor xcor
        set initYcor ycor
       ]
                
  
  reset-ticks 
end

;;Main loop
to go
  ask turtles [
   
    look_for_a_safe_spot
    form_a_group
    run_away
    rescue
    go_arround
    move
    stop_here
    die_here
 
 ]
  
  ifelse saved >= citizens * 0.1 and time10 = 0
       [set time10 ticks * 5
         
        if length tempXcor >= 2
             [set meanXcor10 mean tempXcor
              set meanYcor10 mean tempYcor
              set stdXcor10 standard-deviation tempXcor
              set stdYcor10 standard-deviation tempYcor]
        set coo10 cooperativeCitizen / saved * 100
        
        set tempXcor (list)
        set tempYcor (list)
        ]
       
       [ifelse saved >= citizens * 0.3 and time30 = 0
            [set time30 ticks * 5
             
             if length tempXcor >= 2 
                  [set meanXcor30 mean tempXcor
                  set meanYcor30 mean tempYcor
                  set stdXcor30 standard-deviation tempXcor
                  set stdYcor30 standard-deviation tempYcor]
             set coo30 cooperativeCitizen / saved * 100
            
             set tempXcor (list)
             set tempYcor (list)]
            
            [ifelse saved >= citizens * 0.5 and time50 = 0
                  [set time50 ticks * 5
                  
                   if length tempXcor >= 2 
                        [set meanXcor50 mean tempXcor
                        set meanYcor50 mean tempYcor
                        set stdXcor50 standard-deviation tempXcor
                        set stdYcor50 standard-deviation tempYcor]
                   set coo50 cooperativeCitizen / saved * 100
                   
                   set tempXcor (list)
                   set tempYcor (list)]
                  
                  [ifelse saved >= citizens * 0.8 and time80 = 0
                       [set time80 ticks * 5
                        
                        if length tempXcor >= 2 
                             [set meanXcor80 mean tempXcor
                              set meanYcor80 mean tempYcor
                              set stdXcor80 standard-deviation tempXcor
                              set stdYcor80 standard-deviation tempYcor]
                        
                        set coo80 cooperativeCitizen / saved * 100
                        
                        set tempXcor (list)
                        set tempYcor (list)]
                       
                       [ifelse saved >= citizens * 0.95 and time95 = 0
                             [set time95 ticks * 5
                               
                              if length tempXcor >= 2
                                   [set meanXcor95 mean tempXcor
                                    set meanYcor95 mean tempYcor
                                    set stdXcor95 standard-deviation tempXcor
                                    set stdYcor95 standard-deviation tempYcor]
                              
                              set coo95 cooperativeCitizen / saved * 100
                              
                              set tempXcor (list)
                              set tempYcor (list)]
                             
                             [if count turtles = 0
                                  [set time_final ticks * 5
                                    
                                   if length tempXcor >= 2
                                        [set meanXcor_final mean tempXcor
                                        set meanYcor_final mean tempYcor
                                        set stdXcor_final standard-deviation tempXcor
                                        set stdYcor_final standard-deviation tempYcor]
                                        
                                   set coo_final cooperativeCitizen / saved * 100
                                    
                                   set survivors saved / citizens * 100
                                   stop]
                                 
                             ]
                             
                             
                       ]
                  ]
            ] 
       ] 
  
  
  tsunami

  tick
   
  
  
end



;; Agents look fot the closest one of the evacuation points that they know
to look_for_a_safe_spot
  
   set heading direction
   ;let my_EP one-of patches in-cone 400 1 with [EvacuationPoint = 1]
   let my_safeSpot min-one-of n-of EP_knowledge safeSpot [distance myself] 
   let other_one one-of other turtles in-cone (radius / 10) 360
 
 
      
  if (my_safeSpot != nobody and flight = 0 and chosenEP = 0) 
  or ( my_safeSpot != nobody and newInformation = 1 and distance my_safeSpot < distance my_EP)
    [face my_safeSpot
      set chosenEP 1
      set my_EP my_safeSpot
      set newInformation 0
      set direction heading]
    
  if EP_knowledge = 0 and other_one != nobody and not any? other turtles-here
     [face other_one
      set direction [heading] of other_one]
    
end



;; Agents may try to form groups. In this case they obtain knowledge about EP locations from the best
;; informed gropu member 
to form_a_group
  
  if (cooperation = true) and (count other turtles in-cone 1 360) < min_group_members and [pcolor] of patch-here > 64
      [let groupCenter max-one-of other turtles in-cone (radius / 10) 120 [count other turtles in-cone 1 360]
       let my_knowledge EP_knowledge
    
          if groupCenter != nobody and [cooperation] of groupCenter = true
             [face groupCenter
              ask groupCenter [set color blue
              set speed mean [speed] of turtles in-cone 1 360
              let max_knowledge max-one-of turtles in-cone 1 360 [EP_knowledge]
                   if my_knowledge < [EP_knowledge] of max_knowledge
                      [set EP_knowledge [EP_knowledge] of max_knowledge
                        set newInformation 1]
                               ]
            ]
       ]
  
  
  
end


to run_away
  
  let dryPatch one-of patches in-cone 1 360 with [pcolor < 75]
  
  ifelse one-of patches in-cone 1 360 != nobody and [pcolor] of one-of patches in-cone 3 120 = 95.1 and dryPatch != nobody
  [ face dryPatch
    set flight 1
    set speed speed + 0.2
  ]
  [set flight 0]
   
  
end


;; Agents may try to rescue other ones that are related with them (relation is determined by group number difference)
to rescue
   
   let my_direction direction
   lt 180
   let my_group group
   let my_knowledge EP_knowledge
   let my_speed speed
   let friend one-of turtles in-cone 1.5 180 with [abs(group - my_group) < max_group_diff and (distance myself > 0.6)] 
   
   
  ifelse friend != nobody and [rescue_attempt] of friend = 0
     [face friend
       set color pink
       
          ifelse [EP_knowledge] of friend > my_knowledge
              [set EP_knowledge [EP_knowledge] of friend
                set newInformation 1]
              [ask friend [set EP_knowledge my_knowledge]
               set rescue_attempt 1 
               set direction my_direction
               set newInformation 1
              ]
    
          ifelse [speed] of friend > my_speed
              [set speed [speed] of friend]
              [ask friend [set speed my_speed]]
    ]
    [rt 180
      set color black]
  
end


;; Agents turn around when they reach inacessible terrain
to go_arround
  
 if (patch-ahead 2 != nobody and [pcolor] of patch-ahead 2 = 74.4) or patch-ahead 2 = nobody
  [lt 180
    set direction heading]
   
  
end

to move
  
  fd speed
  
end



to stop_here
    if [pcolor] of patch-here < 27
       [set saved saved + 1
        
        if cooperation = true 
            [set cooperativeCitizen cooperativeCitizen + 1]
        
        ifelse not is-list? tempXcor or empty? tempXcor
            [set tempXcor (list initXcor)
             set tempYcor (list initYcor)]
            [set tempXcor lput initXcor tempXcor
             set tempYcor lput initYcor tempYcor]
        die] 
end


to die_here
  if [pcolor] of patch-here = 95.1
     [die]
end



to tsunami
  
 if ticks > 180
    [ask patches with [pcolor = 95.1]
    [ask patches in-radius 3.5 with [pcolor > 64] [set pcolor 95.1] ]
    ]
  
  if (count patches with [pcolor > 64 and pcolor < 70]) = 0 and random-float 0.9 < 0.3
      [ask patches with [pcolor = 95.1]
      [ask neighbors with [pcolor > 40] [set pcolor 95.1] ]
      ]
  
end
@#$#@#$#@
GRAPHICS-WINDOW
332
11
744
444
100
100
2.0
1
10
1
1
1
0
0
0
1
-100
100
-100
100
0
0
1
ticks
30.0

BUTTON
19
54
180
87
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
20
18
180
51
Setup
mapa
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
16
272
279
443
Safe (%)
Time
saved
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -13345367 true "" "plot saved / citizens * 100"

SLIDER
15
223
278
256
av_EP_knowledge
av_EP_knowledge
0
10
4
1
1
spots
HORIZONTAL

SLIDER
766
271
938
304
group_count
group_count
1
citizens
1
1
1
groups
HORIZONTAL

SLIDER
17
139
161
172
citizens
citizens
100
400
300
25
1
people
HORIZONTAL

SLIDER
764
409
936
442
max_group_diff
max_group_diff
0
group_count
1
1
1
NIL
HORIZONTAL

TEXTBOX
22
104
172
134
Number of citizents in danger zone
12
0.0
1

TEXTBOX
18
187
287
220
Number of EP known by average citizen
12
0.0
1

TEXTBOX
766
195
952
217
Helping friends
16
14.0
0

TEXTBOX
767
229
1076
262
Number of different groups \nexisting in the community
12
0.0
1

TEXTBOX
766
325
1084
400
Maximum group number difference of two agents\nthat allow them to help each other\n0 - no one helps other\n1 - agents help only mebers of own group\nmax - everyone helps other
12
0.0
1

PLOT
1059
130
1245
281
Speed
NIL
NIL
0.3
1.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -13345367 true "set-histogram-num-bars 40" "histogram [speed] of turtles"

PLOT
1061
300
1245
449
EP knowledge
NIL
NIL
0.0
10.1
0.0
100.0
true
false
"" ""
PENS
"default" 1.0 1 -14439633 true "set-histogram-num-bars 40" "histogram [EP_knowledge] of turtles"

TEXTBOX
763
95
953
140
Number of gropu mebers above which they stop trying to join other groups
12
0.0
1

SLIDER
760
148
964
181
min_group_members
min_group_members
2
citizens
4
1
1
people
HORIZONTAL

TEXTBOX
766
15
916
45
Percentage of citizens eager to cooperate
12
0.0
1

SLIDER
763
50
942
83
cooperative_citizens
cooperative_citizens
0
100
100
10
1
%
HORIZONTAL

TEXTBOX
981
16
1131
46
Radius in which citizens search for others
12
0.0
1

SLIDER
981
53
1153
86
radius
radius
10
100
100
10
1
meters
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

Model allows to compare efficiency of tsunami evacuation considering
different types of community members behavior - cooperative and selfish.

## HOW IT WORKS

Depending on behavior that is set for the community in given experiment
agents my try to help each other, share information about locations of avalaible
evacuation points. However, every form of cooperation in this model cost agent a time. Therefore well informed individuals should evacuate faster if they do not cooperate with others. Thanks to this model we can check how different behavior affects evacuation of the whole community.

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
0
Rectangle -7500403 true true 151 225 180 285
Rectangle -7500403 true true 47 225 75 285
Rectangle -7500403 true true 15 75 210 225
Circle -7500403 true true 135 75 150
Circle -16777216 true false 165 76 116

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.0.5
@#$#@#$#@
@#$#@#$#@
1.0 
    org.nlogo.sdm.gui.AggregateDrawing 4 
        org.nlogo.sdm.gui.StockFigure "attributes" "attributes" 1 "FillColor" "Color" 225 225 182 69 87 60 40 
            org.nlogo.sdm.gui.WrappedStock "" "" 0   
        org.nlogo.sdm.gui.ConverterFigure "attributes" "attributes" 1 "FillColor" "Color" 130 188 183 258 108 50 50 
            org.nlogo.sdm.gui.WrappedConverter "" ""   
        org.nlogo.sdm.gui.RateConnection 3 141 114 189 122 238 131 NULL NULL 0 0 0 
            org.jhotdraw.standard.ChopBoxConnector REF 1  
            org.jhotdraw.figures.ChopEllipseConnector 
                org.nlogo.sdm.gui.ReservoirFigure "attributes" "attributes" 1 "FillColor" "Color" 192 192 192 237 118 30 30   
            org.nlogo.sdm.gui.WrappedRate "" "" REF 2 
                org.nlogo.sdm.gui.WrappedReservoir  0   REF 8
@#$#@#$#@
<experiments>
  <experiment name="Ewakuacja" repetitions="30" runMetricsEveryStep="false">
    <setup>mapa</setup>
    <go>go</go>
    <metric>ocalali</metric>
    <metric>czas</metric>
    <enumeratedValueSet variable="max_roznica_grupy">
      <value value="0"/>
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min_licznosc_grupy">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="liczba_mieszkancow">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratownicy">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="liczba_grup">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sr_znajomosc_PE">
      <value value="1"/>
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="laczenie_w_grupy">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment2" repetitions="30" runMetricsEveryStep="false">
    <setup>mapa</setup>
    <go>go</go>
    <metric>survivors</metric>
    <metric>time10</metric>
    <metric>time30</metric>
    <metric>time50</metric>
    <metric>time80</metric>
    <metric>time95</metric>
    <metric>time_final</metric>
    <metric>meanXcor10</metric>
    <metric>meanYcor10</metric>
    <metric>meanXcor30</metric>
    <metric>meanYcor30</metric>
    <metric>meanXcor50</metric>
    <metric>meanYcor50</metric>
    <metric>meanXcor80</metric>
    <metric>meanYcor80</metric>
    <metric>meanXcor95</metric>
    <metric>meanYcor95</metric>
    <metric>meanXcor_final</metric>
    <metric>meanYcor_final</metric>
    <metric>stdXcor10</metric>
    <metric>stdYcor10</metric>
    <metric>stdXcor30</metric>
    <metric>stdYcor30</metric>
    <metric>stdXcor50</metric>
    <metric>stdYcor50</metric>
    <metric>stdXcor80</metric>
    <metric>stdYcor80</metric>
    <metric>stdXcor95</metric>
    <metric>stdYcor95</metric>
    <metric>stdXcor_final</metric>
    <metric>stdYcor_final</metric>
    <metric>coo10</metric>
    <metric>coo30</metric>
    <metric>coo50</metric>
    <metric>coo80</metric>
    <metric>coo95</metric>
    <metric>coo_final</metric>
    <enumeratedValueSet variable="cooperative_citizens">
      <value value="0"/>
      <value value="25"/>
      <value value="50"/>
      <value value="75"/>
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="av_EP_knowledge">
      <value value="1"/>
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max_group_diff">
      <value value="0"/>
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="group_count">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="radius">
      <value value="30"/>
      <value value="50"/>
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="citizens">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min_group_members">
      <value value="4"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
