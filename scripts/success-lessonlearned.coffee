# Description:
#   Records messages containing #success or #lessonlearned on a Google form.
# Commands:
#   #success - records the entire message as a success story.
#   #lessonlearned - records the entire message as a lesson learned.

sheets = {
    "success": {
        "formKey": "1i9Q24ZMbWGagGuijiZMWnk-w35fh_aeQ-ilc5opHIug"
        "nameEntry": "1577228370"
        "textEntry": "695632233"
    }
    "lessonlearned": {
        "formKey": "1rWinK9NGtnBC_umwwb8XJTfAkBO3KUf-8DKTP0a6SMA"
        "nameEntry": "2027214194"
        "textEntry": "667865451"
    }
}

module.exports = (robot) -> 
    robot.hear /.*#((success)|(lessonlearned)).*/i, (msg) ->
        type = msg.match[1]
        text = msg.message.text
        user = msg.message.user.name
        s = sheets[type]
        uri = "https://docs.google.com/forms/d/" + s["formKey"] + "/formResponse"
        data = "entry." + s["nameEntry"] + "=" + user +
                   "&entry." + s["textEntry"] + "=" + encodeURIComponent(text) +
                   "&submit=Submit"
        robot.http(uri + "?" + data)
             .get() (err, res, body) ->
                if err
                    msg.send "Something went wrong with recording your story: #{err}"
                    return
                msg.send "Story recorded, #{user}!"