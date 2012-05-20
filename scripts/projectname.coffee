words = [
  [ "Open", "Free", "Libre", "Universal", "Future" ]
  [ "Content", "Knowledge", "Web", "P2P", "Freedom", "Liberty", "Learning", "Resource", "Salad", "Wiki", "Art", "Squirrel", "Everything", "Hardware", "Media", "Music", "Science", "Standard" ]
  [ "Foundation", "Studio", "University", "Space", "Camp", "Initiative", "Labs", "Library", "Festival", "Conference", "Meetup", "Project", "Group", "Philosophy" ]
]

randomName = ->
  name = []
  i = 0

  while i < words.length
    name.push words[i][Math.floor(Math.random() * words[i].length)]
    i += 1

  name.join(" ")

module.exports = (robot) ->
  robot.respond /name (my |a |the )?project/i, (msg) ->
    msg.send "What about '#{randomName()}'?"

  robot.hear /should I rename/i, (msg) ->
    msg.send "Yes. What don't you call it '#{randomName()}'?"

  robot.hear /how (can|do|would) I/i, (msg) ->
    msg.send "Have you tried using theDataHub?"

  robot.hear /data/i, (msg) ->
    msg.send "Is it on datahub.io?"
