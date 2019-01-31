//
//  PhotoCommand.swift
//  App
//
//  Created by Koray Koska on 31.01.19.
//

import Vapor
import TelegramBot
import TelegramBotPromiseKit
import PromiseKit

class PhotoCommand: BaseCommand {

    static let command: String = ""

    static func isParsable(message: TelegramMessage, botName: String) -> Bool {
        guard let photos = message.photo else {
            return false
        }
        guard let _ = photos.last else {
            return false
        }

        // We can work with that photo. Return true
        return true
    }

    let message: TelegramMessage

    let token: String

    let apiKey: String

    required init(message: TelegramMessage, token: String, apiKey: String) {
        self.message = message
        self.token = token
        self.apiKey = apiKey
    }

    func run() throws {
        let chat = message.chat
        let chatId = chat.id
        let messageId = message.messageId

        var buttonRows: [[TelegramInlineKeyboardButton]] = []

        let analyzeButton = TelegramInlineKeyboardButton(text: "Analyze!", callbackData: AnalyzeInlineCallbackQuery.callbackData)
        buttonRows.append([analyzeButton])

        let inlineKeyboard = TelegramInlineKeyboardMarkup(inlineKeyboard: buttonRows)

        let sendApi = TelegramSendApi(token: token, provider: SnakeTelegramProvider(token: token))

        let sendMessage = TelegramSendMessage(
            chatId: chatId,
            text: "Analyze?",
            replyToMessageId: messageId,
            replyMarkup: .inlineKeyboardMarkup(keyboard: inlineKeyboard)
        )

        sendApi.sendMessage(message: sendMessage)
    }
}
