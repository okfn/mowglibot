# Description:
#   Query and update Nagios
#
# Commands:
#   !host <hostname> - Get basic status information about host
#   !down <hostname> <duration> - Schedule downtime for the given host
#   !up <hostname> - Clear any scheduled downtime for the given host

request = require('request')
parseDuration = require('parse-duration')


NAGIOS_API_ROOT = process.env["NAGIOS_API_ROOT"] || "http://nagios.okfn.org/api"
NAGIOS_AUTH_USER = process.env["NAGIOS_AUTH_USER"]
NAGIOS_AUTH_PASS = process.env["NAGIOS_AUTH_PASS"]
NAGIOS_DEFAULT_DOMAIN = process.env["NAGIOS_DEFAULT_DOMAIN"] || "okserver.org"


HOST_STATE_MAP =
  "0": "UP"
  "1": "DOWN/UNREACHABLE"
  "2": "DOWN/UNREACHABLE"
  "3": "DOWN/UNREACHABLE"


normaliseHostname = (hostname) ->
  if hostname.indexOf('.') != -1
    return hostname.toLowerCase()
  else
    return "#{hostname}.#{NAGIOS_DEFAULT_DOMAIN}".toLowerCase()


getHostState = (hostname, callback) ->
  request.get({
    url: "#{NAGIOS_API_ROOT}/state"
    auth:
      user: NAGIOS_AUTH_USER
      pass: NAGIOS_AUTH_PASS
      sendImmediately: true
    json: true
  }, (e, resp, body) ->
    if e?
      callback(e, resp, body)
      return

    if !body.content?[hostname]?
      callback("no host in nagios with hostname '#{hostname}'", resp, body)
      return

    callback(e, resp, body.content[hostname])
  )


scheduleDowntime = (hostname, duration, callback) ->
  request.post({
    url: "#{NAGIOS_API_ROOT}/schedule_downtime"
    auth:
      user: NAGIOS_AUTH_USER
      pass: NAGIOS_AUTH_PASS
      sendImmediately: true
    json:
      host: hostname
      duration: duration
  }, (e, resp, body) ->
    if e?
      callback(e, resp, body)
      return

    if not body.success
      callback(body.content, resp, body)
      return

    callback(e, resp, body)
  )


cancelDowntime = (hostname, callback) ->
  request.post({
    url: "#{NAGIOS_API_ROOT}/cancel_downtime"
    auth:
      user: NAGIOS_AUTH_USER
      pass: NAGIOS_AUTH_PASS
      sendImmediately: true
    json:
      host: hostname
  }, (e, resp, body) ->
    if e?
      callback(e, resp, body)
      return

    if not body.success
      callback(body.content, resp, body)
      return

    callback(e, resp, body)
  )


module.exports = (robot) ->


  robot.hear /!host\s+(\S+)/i, (msg) ->
    hostname = normaliseHostname(msg.match[1])

    getHostState(hostname, (e, resp, body) ->
      if e?
        msg.send("Error retrieving host state: #{e}")
      else
        state = HOST_STATE_MAP[body.current_state]
        detail = body.plugin_output
        msg.send("Host state for #{hostname}: #{state} (#{detail})")
    )


  robot.hear /!down\s+(\S+)(.+)$/i, (msg) ->
    hostname = normaliseHostname(msg.match[1])
    duration = parseDuration(msg.match[2]) / 1000 # parseDuration returns ms

    if duration < 60
      msg.send("Usage: !down <hostname> <duration>")
      msg.send("e.g. !down s123 10m")
      msg.send("Error: couldn't parse duration or duration was less than 60s!")
      return

    scheduleDowntime(hostname, duration, (e, resp, body) ->
      if e?
        msg.send("Error scheduling downtime: #{e}")
      else
        msg.send("#{duration}s downtime scheduled for #{hostname}! " +
                 "(content=#{body.content})")
    )


  robot.hear /!up\s+(\S+)/i, (msg) ->
    hostname = normaliseHostname(msg.match[1])

    cancelDowntime(hostname, (e, resp, body) ->
      if e?
        msg.send("Error cancelling downtime: #{e}")
      else
        msg.send(
          "Downtime cancelled for #{hostname}! (content=#{body.content})")
    )
