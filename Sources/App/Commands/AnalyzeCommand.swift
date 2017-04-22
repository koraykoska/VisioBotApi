//
//  AnalyzeCommand.swift
//  VisioBotApi
//
//  Created by Koray Koska on 22/04/2017.
//
//

import Vapor
import RandomKit

class AnalyzeCommand: BaseCommand {

    static let command: String? = "/analyze"

    let message: JSON

    required init(message: JSON) {
        self.message = message
    }

    func run() throws {
        let chat = message["chat"]
        guard let chatId = chat?["id"]?.int else {
            drop.log.warning("Is someone trying to hijack our server? Chat id was nil...")
            throw Abort.badRequest
        }

        guard let photos = message["reply_to_message"]?["photo"]?.array else {
            // TODO: Send message with expenation how to use the /analyze command
            return
        }
        let bestPhoto = photos[photos.count - 1]

        guard let fileId = bestPhoto.object?["file_id"]?.string else {
            drop.log.warning("Is someone trying to hijack our server? Photo id was nil...")
            throw Abort.badRequest
        }

        let response = try TelegramApi.getFile(fileId: fileId)

        guard let filePath = response.json?["result"]?["file_path"]?.string else {
            drop.log.warning("Is someone trying to hijack our server? Photo file_path was nil...")
            throw Abort.badRequest
        }

        let imageResponse = try TelegramApi.downloadImage(filePath: filePath)

        guard let imageBytes = imageResponse.body.bytes else {
            // TODO: Send message with explenation that the image could not be downloaded
            return
        }

        let visionResponse = try GoogleVisionApi.annotate(imageBytes: imageBytes)

        guard let responses = visionResponse.json?["responses"]?.array, responses.count > 0, let labels = responses[0].object?["labelAnnotations"]?.array else {
            // TODO: Something went wrong with the vision api request or we have no assumptions. Inform the user...
            return
        }

        let texts = [
            "Oh I know, it's a",
            "Do you thing that's a",
            "This kinda looks like a"
        ]
        for label in labels {
            if let l = label.object?["description"]?.string {
                let number = Int.random(within: 0 ..< texts.count, using: &Xoroshiro.default)!
                let text = "\(texts[number]) *\(l)*"
                let replyMessageId = message["reply_to_message"]?["message_id"]?.int
                let _ = try TelegramApi.sendMessage(chatId: String(chatId), text: text, parseMode: .markdown, replyToMessageId: replyMessageId)
            }
        }
    }
}
