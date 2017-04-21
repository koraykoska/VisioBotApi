import Vapor

let drop = Droplet()

drop.get { req in
    return try drop.view.make("welcome", [
    	"message": drop.localization[req.lang, "welcome", "title"]
    ])
}

drop.resource("posts", PostController())

guard let token = drop.config["app", "TELEGRAM_TOKEN"]?.string! else {
    throw Abort.serverError
}
// Set telegram token so it can be used
ConfigHolder.telegramToken = token

let t = TelegramController()
drop.post(token, handler: t.telegramBaseRequest)

drop.run()
