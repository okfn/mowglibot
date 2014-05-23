# Description:
#   Tell people who mowgli is.

module.exports = (robot) ->
  robot.respond /wh(o|at) are you\?$/i, (msg) ->
    msg.send "Me? I'm Open Knowledge's resident friendly chatbot! https://github.com/okfn/mowglibot"
