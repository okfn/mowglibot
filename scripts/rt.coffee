# Description:
#   Fetch titles and links to RT tickets
#
# Commands:
#   RT#nr - Get title and link to this ticket

request = require('request')

RT = "https://rt.okfn.org"


parseBody = (body) ->
  out = {}
  for line in body.split('\n')
    m = line.match(/^([a-z]+): (.+)$/i)
    if m
      out[m[1]] = m[2]
  return out


fillAuthCookie = (jar, callback) ->
  request.post(RT, {
    jar: jar,
    form: {
      user: process.env['RT_USER']
      pass: process.env['RT_PASS']
    }
  }, callback)


getTicketDetails = (id, jar, callback) ->
  request "#{RT}/REST/1.0/ticket/#{id}/show", {jar: jar},  (e, resp, body) ->
    if e?
      callback(e, null, resp, body)
      return

    if body.match(/does not exist/)
      callback(null, null, resp, body)
    else
      tkt = parseBody(body)
      callback(null, tkt, resp, body)


module.exports = (robot) ->

  # Hear a ticket number? Fetch some metadata
  robot.hear /\bRT#(\d+)\b/i, (msg) ->
    id = msg.match[1]
    jar = request.jar()

    fillAuthCookie jar, (e, resp, body) ->
      if e?
        console.log(e, body)
        msg.send("Error retrieving ticket ##{id}. See the logs.")
        return

      getTicketDetails id, jar, (e, tkt, resp, body) ->
        if e?
          console.log(e, body)
          msg.send("Error retrieving ticket ##{id}. See the logs.")
        else if tkt?
          msg.send("##{id}: #{tkt.Subject} " +
                   "(owner: #{tkt.Owner}, creator: #{tkt.Creator}) " +
                   "#{RT}/Ticket/Display.html?id=#{id}")
        else
          msg.send("##{id} does not exist in RT. Sorry.")
