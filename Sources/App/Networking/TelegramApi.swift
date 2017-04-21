//
//  TelegramApi.swift
//  VisioBotApi
//
//  Created by Koray Koska on 21/04/2017.
//
//

import Vapor
import HTTP

class TelegramApi {

    static let baseUrl: (_ methodName: String) -> String = { methodName in
        return "https://api.telegram.org/bot\(ConfigHolder.telegramToken)/\(methodName)"
    }

    class func sendMessage(chatId: String, text: String, parseMode: TelegramApiParseMode? = nil, disableWebPagePreview: Bool? = nil, disableNotification: Bool? = nil, replyToMessageId: Int? = nil, replyMarkup: ReplyMarkup? = nil) throws -> Response {

        var message = try JSON(node: [
            "chat_id": chatId,
            "text": text
            ])
        if let parseMode = parseMode {
            message["parse_mode"] = JSON(Node(parseMode.rawValue))
        }

        let response = try drop.client.post(baseUrl("sendMessage"), headers: [:], body: message.makeBody())

        return response
    }
}
