# Description:
#   Ensures compliance with the OKF^WOpen Knowledge Foundation's no-acronym
#   policy.

module.exports = (robot) ->
  robot.hear /\b((okfn(?!(\/|\.[a-z]+)))|(okf(?!n?(\/|\.[a-z]+)))|okfest)\b/i, (msg) ->
    msg.reply "Is that an acronym/initialism/abbreviation I hear...?"

