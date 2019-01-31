import Vapor
import TelegramBot
import TelegramBotVapor

/// Register your application's routes here.
public func routes(_ router: Router, _ customConfigService: CustomConfigService) throws {
    // Telegram webhooks
    let telegramBot = TelegramReceiveApi()
    let controller = BotController(
        botName: customConfigService.botName,
        token: customConfigService.telegramToken,
        apiKey: customConfigService.googleVisionApiKey
    )

    telegramBot.messageUpdate = controller.getMessage
    telegramBot.callbackQueryUpdate = controller.getCallback

    telegramBot.setupWebhook(path: customConfigService.telegramToken, routerFunction: router.telegramRegister)
}
