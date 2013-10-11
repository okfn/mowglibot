words = [
  [ "Open", "Free", "Libre", "Universal", "Future" ]
  [ "Content", "Knowledge", "Web", "P2P", "Freedom", "Liberty", "Learning", "Resource", "Salad", "Wiki", "Art", "Squirrel", "Everything", "Hardware", "Media", "Music", "Science", "Standard", "Okapi", "Axolotl" ]
  [ "Foundation", "Studio", "University", "Space", "Camp", "Initiative", "Labs", "Library", "Festival", "Conference", "Meetup", "Project", "Group", "Philosophy", "Cluster", "Hub", "Standard" ]
]

qs = [ "Have you thought about", "What about", "What do you think of", "Why don't you call it" ]

randomName = ->
  name = []
  i = 0

  while i < words.length
    name.push words[i][Math.floor(Math.random() * words[i].length)]
    i += 1

  name.join(" ")

module.exports = (robot) ->
  robot.respond /name (my |a |the )?project/i, (msg) ->
    msg.send msg.random(qs) + " '#{randomName()}'?"

  robot.hear /should I rename/i, (msg) ->
    msg.send "Yes. " + msg.random(qs) + " '#{randomName()}'?"
