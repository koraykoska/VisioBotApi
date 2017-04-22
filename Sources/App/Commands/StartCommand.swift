//
//  StartCommand.swift
//  VisioBotApi
//
//  Created by Koray Koska on 21/04/2017.
//
//

import Vapor

class StartCommand: BaseCommand {

    static let command: String = "/start"

    let message: JSON

    required init(message: JSON) {
        self.message = message
    }

    func run() throws {
        let chat = message["chat"]
        guard let chatId = chat?["id"]?.int else {
            return
        }
        let chatTitle = chat?["title"]?.string
        let chatFirstName = chat?["first_name"]?.string

        var chatName = "1 Larry"
        if let chatTitle = chatTitle {
            chatName = chatTitle
        } else if let chatFirstName = chatFirstName {
            chatName = chatFirstName
        }

        let text = "Hi \(chatName)! You are now officially part of the NSA espionage network. Please feel free and reply to a photo with the command /analyze so we can analyze it to make America secure again!"

        let _ = try TelegramApi.sendMessage(chatId: String(chatId), text: text)
    }
}
