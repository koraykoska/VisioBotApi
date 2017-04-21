import Vapor

let drop = Droplet()

drop.get { req in
    return try drop.view.make("welcome", [
    	"message": drop.localization[req.lang, "welcome", "title"]
    ])
}

drop.resource("posts", PostController())

let t = TelegramController()
guard let token = drop.config["app", "TELEGRAM_TOKEN"]?.string! else {
    throw Abort.serverError
}
drop.post(token, handler: t.telegramBaseRequest)

drop.run()
