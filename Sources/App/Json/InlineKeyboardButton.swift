//
//  InlineKeyboardButton.swift
//  VisioBotApi
//
//  Created by Koray Koska on 22/04/2017.
//
//

import Vapor

class InlineKeyboardButton: JSONRepresentable {

    let text: String
    let url: String?
    let callbackData: String?
    let switchInlineQuery: String?
    let switchInlineQueryCurrentChat: String?
    let callbackGame: CallbackGame?

    init(text: String, url: String? = nil, callbackData: String? = nil, switchInlineQuery: String? = nil, switchInlineQueryCurrentChat: String? = nil, callbackGame: CallbackGame? = nil) {
        self.text = text
        self.url = url
        self.callbackData = callbackData
        self.switchInlineQuery = switchInlineQuery
        self.switchInlineQueryCurrentChat = switchInlineQueryCurrentChat
        self.callbackGame = callbackGame
    }

    func makeJSON() throws -> JSON {
        var node: [String: NodeRepresentable] = [
            "text": text
        ]
        if let url = url {
            node["url"] = url
        }
        if let callbackData = callbackData {
            node["callback_data"] = callbackData
        }
        if let switchInlineQuery = switchInlineQuery {
            node["switch_inline_query"] = switchInlineQuery
        }
        if let switchInlineQueryCurrentChat = switchInlineQueryCurrentChat {
            node["switch_inline_query_current_chat"] = switchInlineQueryCurrentChat
        }
        if let callbackGame = callbackGame {
            node["callback_game"] = try callbackGame.makeJSON()
        }
        return try JSON(node: node)
    }
}
