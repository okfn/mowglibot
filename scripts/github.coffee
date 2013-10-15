# Description:
#   Fetch titles and links to GitHub issues
#
# Commands:
#   user/repo#nr - Get title and link to this issue

module.exports = (robot) ->

  robot.hear /\b([^\s\/#]+)\/([^\s\/#]+)#(\d+)\b/i, (msg) ->
    user = msg.match[1]
    repo = msg.match[2]
    issue = msg.match[3]
    msg.http("https://api.github.com/repos/#{user}/#{repo}/issues/#{issue}")
      .get() (err, res, body) ->
        obj = JSON.parse(body)
        if obj.title and obj.html_url
          msg.send "#{obj.title}: #{obj.html_url}"
