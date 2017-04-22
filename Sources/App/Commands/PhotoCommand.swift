//
//  PhotoCommand.swift
//  VisioBotApi
//
//  Created by Koray Koska on 22/04/2017.
//
//

import Vapor

class PhotoCommand: BaseCommand {

    static let command: String? = nil

    static func isParsable(message: JSON) -> Bool {
        guard let photos = message["photo"]?.array else {
            return false
        }
        guard let lastPhoto = photos[photos.count - 1].object else {
            return false
        }
        guard let _ = lastPhoto["file_id"]?.string else {
            return false
        }

        // We can work with that photo. Return true
        return true
    }

    let message: JSON

    required init(message: JSON) {
        self.message = message
    }

    func run() throws {
        let chat = message["chat"]
        guard let chatId = chat?["id"]?.int, let messageId = message["message_id"]?.int else {
            return
        }
        guard PhotoCommand.isParsable(message: message) else {
            return
        }

        var buttonRows: [[InlineKeyboardButton]] = []

        let analyzeButton = InlineKeyboardButton(text: "Analyze!", callbackData: AnalyzeInlineCallbackQuery.callbackData)
        buttonRows.append([analyzeButton])

        let inlineKeyboard = InlineKeyboardMarkup(inlineKeyboardButtonRows: buttonRows)
        drop.log.debug("*** InlineKeyboardMarkup ***")
        drop.log.debug(try inlineKeyboard.makeJSON().serialize().string())
        let response = try TelegramApi.sendMessage(chatId: String(chatId), text: "Analyze?", replyToMessageId: messageId, replyMarkup: inlineKeyboard)
        drop.log.debug("*** sendMessage response ***")
        drop.log.debug(response.description)
    }
}
