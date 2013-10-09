Q = require 'q'
geocoder = require 'geocoder'
timezoner = require 'timezoner'


DEFAULT_TIMEZONES =
  "US East": [42.3584308, -71.0597732]
  "UK":      [51.511214, -0.1198244]
  "Germany": [52.519171, 13.4060912]
  "India":   [20.593684, 78.96288]


utcNow = ->
  Math.round((new Date()).getTime() / 1000)


pad = (num) ->
  if num < 10
    '0' + num
  else
    '' + num


getOffsetTime = (offset) ->
  d = new Date((utcNow() + offset) * 1000)
  pad(d.getUTCHours()) + ':' + pad(d.getUTCMinutes())


fetchLocation = (name) ->
  dfd = Q.defer()
  if name of DEFAULT_TIMEZONES
    [lat, lng] = DEFAULT_TIMEZONES[name]
    dfd.resolve(lat: lat, lng: lng)
  else
    geocode = Q.ninvoke(geocoder, 'geocode', name)
               .then (data) ->
                  if data.status? and data.status == 'OK'
                    return data.results[0].geometry.location
                  else
                    throw new Error('Geocoding failed: ' + JSON.stringify(data))
    dfd.resolve(geocode)
  return dfd.promise


fetchTimezone = (loc) ->
  Q.ninvoke(timezoner, 'getTimeZone', loc.lat, loc.lng)


# Get times for a timezone by location name
getTimezone = (name) ->
  processResults = (tzData) ->
    if tzData.status? and tzData.status == 'OK'
      return name + ': ' + getOffsetTime(tzData.dstOffset + tzData.rawOffset)
    else
      optionalErrorMsg = ''
      if tzData.error_message?
        optionalErrorMsg = ' (' + tzData.error_message + ')'
      return name + ': ' + tzData.status + optionalErrorMsg

  processError = (err) -> name + ': ' + err

  return fetchLocation(name)
  .then(fetchTimezone)
  .then(processResults, processError)


# Get times for all the default timezones
getDefaultTimezones = (msg) ->
  timezones = Object.keys(DEFAULT_TIMEZONES)

  Q.all(timezones.map (tz) -> getTimezone(tz))

module.exports = (robot) ->
  robot.hear /!(tz|times?|timezones)$/i, (msg) ->
    getDefaultTimezones()
    .done (res) -> msg.send(res.join(', '))

  robot.hear /^!(tz|time|timezone)\s+(.+)$/i, (msg) ->
    loc = msg.match[2]
    getTimezone(loc)
    .done (res) -> msg.send(res)
