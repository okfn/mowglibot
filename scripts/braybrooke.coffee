words = [
  [ "Fail", "Free", "Future", "Fabulous", "Fabled", "Fabricated", "Familial", "For", "Fiendish", "Friendly", "French", "Fireproof", "Fleecy", "Fizzy", "Finnish", "Feature-driven", "Formaldehyde", "Fugacious", "Funded", "Futile" ]
  [ "Tabacco", "Tabasco", "Time", "The", "Table", "Tachycardic", "Tree", "Tokenized", "Tangent", "Tarantula", "Target", "Trip", "Transvestite", "Tarot", "Tasmania", "Techie", "Tickle", "Troika", "Trouble", "Tingle", "Three", "Thirty" ]
  [ "Worm", "Wiggle", "Warlock", "Wizard", "Wedding", "Win", "Wafer", "Weirdo", "Waffle", "Waaaasssssuuuupp!", "Wear", "Wanderlust", "Whale", "Whippersnapper", "Weasel", "Whiskey", "Windbag", "Wolfpack", "Wurzel", "Widget" ]
]

randomName = ->
  name = []
  i = 0

  while i < words.length
    name.push words[i][Math.floor(Math.random() * words[i].length)]
    i += 1

  name.join(" ")

module.exports = (robot) ->
  robot.hear /#win/i, (msg) ->
    msg.send '#fail'

  robot.hear /#fail/i, (msg) ->
    msg.send '#win'

  robot.hear /#w(00|oo)t/i, (msg) ->
    msg.send '#rad'

  robot.hear /#rad/i, (msg) ->
    msg.send '#w00t'

#  robot.hear /FTW/i, (msg) ->
#    msg.send "FTW...? #{randomName()}?"


