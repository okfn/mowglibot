# Description:
#   Ensures compliance with the OKF^WOpen Knowledge Foundation's no-acronym
#   policy.

module.exports = (robot) ->
  robot.hear /\b((okfn(?!(\/|\.org)))|(okf(?!n?(\/|\.org)))|okfest)\b/i, (msg) ->
    msg.reply "Is that an acronym/initialism/abbreviation I hear...?"

