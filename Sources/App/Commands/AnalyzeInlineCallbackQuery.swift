//
//  AnalyzeInlineCallbackQuery.swift
//  VisioBotApi
//
//  Created by Koray Koska on 22/04/2017.
//
//

import Vapor

class AnalyzeInlineCallbackQuery: BaseCallbackQuery {

    static let callbackData: String? = "/analyzeinline"

    let callbackQuery: JSON

    required init(callbackQuery: JSON) {
        self.callbackQuery = callbackQuery
    }

    func run() throws {
        guard let id = callbackQuery["id"]?.string, let message = callbackQuery["message"], let _ = message["reply_to_message"] else {
            drop.log.error(try callbackQuery.serialize().string())
            return
        }

        let a = AnalyzeCommand(message: message)
        try a.run()

        let _ = try TelegramApi.answerCallbackQuery(callbackQueryId: id)
    }
}
