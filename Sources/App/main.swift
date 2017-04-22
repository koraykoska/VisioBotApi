import Vapor

let drop = Droplet()

drop.get { req in
    return try drop.view.make("welcome", [
    	"message": drop.localization[req.lang, "welcome", "title"]
    ])
}

drop.resource("posts", PostController())

guard let token = drop.config["app", "TELEGRAM_TOKEN"]?.string! else {
    drop.log.error("The TELEGRAM_TOKEN environment variable must be set!")
    throw Abort.serverError
}
// Set telegram token so it can be used
ConfigHolder.telegramToken = token

guard let botName = drop.config["app", "BOT_NAME"]?.string! else {
    drop.log.error("The BOT_NAME environment variable must be set!")
    throw Abort.serverError
}
// Set bot name so it can be used
ConfigHolder.botName = botName

guard let googleApiKey = drop.config["app", "GOOGLE_API_KEY"]?.string! else {
    drop.log.error("The BOT_NAME environment variable must be set!")
    throw Abort.serverError
}
// Set google API key so it can be used
ConfigHolder.googleApiKey = googleApiKey

let t = TelegramController()
drop.post(token, handler: t.telegramBaseRequest)

drop.run()
