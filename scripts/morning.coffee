# Description:
#   Say good morning to people.

lastGreeting = null

morning = [ "Good morning all!", "Well good morning to you!", "*Yawn*... Morning...", "Morgen" ]
late = [ "Morning? You call this morning?", "Umm. Good afternoon...", "Merry Christmas!^W^WSorry, good morning!" ]

module.exports = (robot) ->

  robot.hear /(^|good )morning/i, (msg) ->
    d = new Date()
    if not lastGreeting or d - lastGreeting > 43200000 or d.getUTCDate() != lastGreeting.getUTCDate()
      lastGreeting = d

      if d.getUTCHours() < 12
        msg.send msg.random morning
      else
        msg.send msg.random late
