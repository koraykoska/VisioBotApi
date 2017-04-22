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
        guard let photos = message["photo"]?.array, let lastPhoto = photos[photos.count - 1].object, let photoId = lastPhoto["file_id"]?.string else {
            return
        }

        var buttonRows: [[InlineKeyboardButton]] = []

        let callbackData = try JSON(node: [
            "file_id": photoId,
            "message_id": messageId
            ])
        let analyzeButton = InlineKeyboardButton(text: "Analyze!", callbackData: try callbackData.serialize().string())
        buttonRows.append([analyzeButton])

        let inlineKeyboard = InlineKeyboardMarkup(inlineKeyboardButtonRows: buttonRows)
        let _ = try TelegramApi.sendMessage(chatId: String(chatId), text: "Analyze?", replyToMessageId: messageId, replyMarkup: inlineKeyboard)
    }
}
