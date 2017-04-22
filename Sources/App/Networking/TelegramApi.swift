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
        return "https://api.telegram.org/bot\(ConfigHolder.telegramToken ?? "")/\(methodName)"
    }

    static let jsonContentTypeHeader: [HeaderKey: String] = ["Content-Type": "application/json"]

    class func sendMessage(chatId: String, text: String, parseMode: TelegramApiParseMode? = nil, disableWebPagePreview: Bool? = nil, disableNotification: Bool? = nil, replyToMessageId: Int? = nil, replyMarkup: ReplyMarkup? = nil) throws -> Response {
        var message = try JSON(node: [
            "chat_id": chatId,
            "text": text
            ])
        if let parseMode = parseMode {
            message["parse_mode"] = JSON(Node(parseMode.rawValue))
        }
        if let disableWebPagePreview = disableWebPagePreview {
            message["disable_web_page_preview"] = JSON(Node(disableWebPagePreview))
        }
        if let disableNotification = disableNotification {
            message["disable_notification"] = JSON(Node(disableNotification))
        }
        if let replyToMessageId = replyToMessageId {
            message["reply_to_message_id"] = JSON(Node(replyToMessageId))
        }
        if let replyMarkup = replyMarkup {
            message["reply_markup"] = try replyMarkup.makeJSON()
        }

        drop.log.debug(baseUrl("sendMessage"))

        let response = try drop.client.post(baseUrl("sendMessage"), headers: jsonContentTypeHeader, body: message.makeBody())

        return response
    }

    class func getFile(fileId: String) throws -> Response {
        let request = try JSON(node: ["file_id": fileId])

        let response = try drop.client.post(baseUrl("getFile"), headers: jsonContentTypeHeader, body: request.makeBody())

        return response
    }

    class func downloadImage(filePath: String) throws -> Response {
        let url = "https://api.telegram.org/file/bot\(ConfigHolder.telegramToken ?? "")/\(filePath)"

        return try drop.client.get(url)
    }
}
