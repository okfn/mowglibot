module.exports = (robot) ->
  robot.respond /wh(o|at) are you\?$/i, (msg) ->
    msg.send "Me? I'm the OKF's resident friendly chatbot! https://github.com/okfn/mowglibot"
