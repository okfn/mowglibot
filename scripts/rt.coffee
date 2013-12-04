# Description:
#   Fetch titles and links to RT tickets
#
# Commands:
#   RT#nr - Get title and link to this ticket

request = require('request')

RT = process.env["RT_URL"] || "https://rt.okfn.org"
RT_EMAIL_ROOM = process.env["RT_EMAIL_ROOM"] || "#tech-team"

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


parseMandrillEvent = (event) ->
  err = (msg) ->
    console.log("Error parsing Mandrill event (#{msg})", event)

  if not event.msg?
    err("no msg field on event")
    return
  msg = event.msg

  ret = {}

  if not msg.subject?
    err("no subject field")
    return
  ret.subject = msg.subject

  if not msg.headers?
    err("no headers field")
    return

  if not msg.headers['X-Rt-Originator']?
    err("X-Rt-Originator header missing")
    return
  # e.g. "X-Rt-Originator: joe@bloggs.com"
  ret.from = msg.headers['X-Rt-Originator']

  if not msg.headers['X-Rt-Ticket']?
    err("X-Rt-Ticket header missing")
    return
  try
    # e.g. "X-Rt-Ticket: example.com #123"
    ret.ticket = msg.headers['X-Rt-Ticket'].split(/\s+/)[1].slice(1)
  catch e
    err("unrecognised format for X-Rt-Ticket header")
    return

  ret.url = "#{RT}/Ticket/Display.html?id=#{ret.ticket}"
  return ret


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

  # Receive Mandrill hook verification
  robot.router.head "/rt/mailhook", (req, res) ->
    res.set('Content-Length', '0')
    res.send(200)

  # Receive Mandrill POSTs for incoming email
  robot.router.post "/rt/mailhook", (req, res) ->
    res.set('Content-Type', 'text/plain')
    res.send("OK\n")

    if not req.body.mandrill_events?
      console.log("Warning: received non-Mandrill email to /rt/mailhook",
                  req.body)
      return

    events = JSON.parse(req.body.mandrill_events)

    for event in events

      parsed = parseMandrillEvent(event)
      if parsed?
        robot.messageRoom(RT_EMAIL_ROOM,
                          "#{parsed.subject} " +
                          "(from: #{parsed.from}) " +
                          "#{parsed.url}")
