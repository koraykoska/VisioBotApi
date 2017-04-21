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

    class func sendMessage(chatId: String, text: String, parseMode: TelegramApiParseMode? = nil, disableWebPagePreview: Bool? = nil, disableNotification: Bool? = nil, replyToMessageId: Int? = nil, replyMarkup: ReplyMarkup) throws -> Response {

        let message = try JSON(node: [
            "chat_id": chatId
            ])
        let jsonBytes = try message.makeBytes()
        let response = try drop.client.post("http://some-endpoint/json", headers: ["Auth": "Token my-auth-token"], body: Body.data(jsonBytes))

        return response
    }
}
