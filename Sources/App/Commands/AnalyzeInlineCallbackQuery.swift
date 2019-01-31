//
//  AnalyzeInlineCallbackQuery.swift
//  App
//
//  Created by Koray Koska on 31.01.19.
//

import Foundation
import TelegramBot

class AnalyzeInlineCallbackQuery: BaseCallbackQuery {

    static let callbackData: String = "/analyzeinline"

    let callbackQuery: TelegramCallbackQuery

    let token: String

    let apiKey: String

    required init(callbackQuery: TelegramCallbackQuery, token: String, apiKey: String) {
        self.callbackQuery = callbackQuery
        self.token = token
        self.apiKey = apiKey
    }

    func run() throws {
        let id = callbackQuery.id
        guard let message = callbackQuery.message, let _ = message.replyToMessage else {
            return
        }

        let a = AnalyzeCommand(message: message, token: token, apiKey: apiKey)
        try a.run()

        let sendApi = TelegramSendApi(token: token, provider: SnakeTelegramProvider(token: token))

        let answer = TelegramSendAnswerCallbackQuery(callbackQueryId: id)

        sendApi.answerCallbackQuery(answerCallbackQuery: answer)

        let chatId = message.chat.id
        let messageId = message.messageId

        let editReplyMarkup = TelegramSendEditMessageReplyMarkup(chatId: .int(id: chatId), messageId: messageId)

        sendApi.editMessageReplyMarkup(editMessageReplyMarkup: editReplyMarkup)
    }
}
