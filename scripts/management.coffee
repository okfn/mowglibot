module.exports = (robot) ->
  robot.hear /\ (executive|management)/i, (msg) ->
    msg.send "Thank you for your message. Your message has been automatically forwarded to executive@okfn.org."
