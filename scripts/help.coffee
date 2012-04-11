# Generates help commands for Hubot.
#
# These commands are grabbed from comment blocks at the top of each file.
#
# help - Displays all of the help commands that Hubot knows about.
# help <query> - Displays all help commands that match <query>.

gist = require 'gist'

module.exports = (robot) ->
  robot.respond /help\s*(.*)?$/i, (msg) ->
    cmds = robot.helpCommands()
    if msg.match[1]
      cmds = cmds.filter (cmd) -> cmd.match(new RegExp(msg.match[1]))
    emit = cmds.join("\n")
    unless robot.name is 'Hubot'
      emit = emit.replace(/(H|h)ubot/g, robot.name)

    if emit.split("\n").length < 4
      msg.send emit
    else
      gist.create emit, (url) ->
        msg.send "I do quite a lot of stuff. See the full list at #{url}"
