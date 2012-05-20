module.exports = (robot) ->
  robot.hear / management/i, (msg) ->
    msg.send "Thank you for your message. Your message has been automatically forwarded to management@okfn.org."
