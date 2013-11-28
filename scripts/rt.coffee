# Description:
#   Fetch titles and links to RT tickets
#
# Commands:
#   RT#nr - Get title and link to this ticket

request = require('request')

RT = "http://rt.okfn.org"

parseBody = (body) ->
  out = {}
  for line in body.split('\n')
    m = line.match(/^([a-z]+): (.+)$/i)
    if m
      out[m[1]] = m[2]
  return out

module.exports = (robot) ->

  robot.hear /\bRT#(\d+)\b/i, (msg) ->
    id = msg.match[1]
    jar = request.jar()

    request.post(
      RT,
      {
        jar: jar,
        form: {
          user: process.env['RT_USER']
          pass: process.env['RT_PASS']
        }
      },
      ->
        request(
          "#{RT}/REST/1.0/ticket/#{id}/show",
          {jar: jar},
          (e, resp, body) ->
            if e
              console.log(e, body)
              msg.send("Error retrieving ticket ##{id}. See the logs.")
              return

            if body.match(/does not exist/)
              msg.send("##{id} does not exist in RT. Sorry.")
            else
              data = parseBody(body)
              msg.send("##{id}: #{data.Subject} (owner: #{data.Owner}, creator: #{data.Creator}) #{RT}/Ticket/Display.html?id=#{id}")
        )
    )
