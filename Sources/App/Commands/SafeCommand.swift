//
//  SafeCommand.swift
//  App
//
//  Created by Koray Koska on 16.02.19.
//

import Vapor
import TelegramBot
import TelegramBotPromiseKit
import PromiseKit

class SafeCommand: BaseCommand {

    enum Error: Swift.Error {

        case imageDownloadFailed
    }

    static let command: String = "#safe"

    let message: TelegramMessage

    let token: String

    let apiKey: String

    required init(message: TelegramMessage, token: String, apiKey: String) {
        self.message = message
        self.token = token
        self.apiKey = apiKey
    }

    func run() throws {
        let chat = message.chat
        let chatId = chat.id

        let fileId: String
        if let photos = message.replyToMessage?.photo {
            let bestPhoto = photos[photos.count - 1]

            fileId = bestPhoto.fileId
        } else if let sticker = message.replyToMessage?.sticker {
            fileId = sticker.fileId
        } else {
            // TODO: Send message with expenation how to use the #sentiment command
            return
        }

        let sendApi = TelegramSendApi(token: token, provider: SnakeTelegramProvider(token: token))

        let queue = DispatchQueue(label: "SafeCommand")

        sendApi.getFile(fileId: fileId).then(on: queue) { file in
            return ImageDownloader.downloadImage(url: "https://api.telegram.org/file/bot\(self.token)/\(file.filePath ?? "")")
        }.then(on: queue) { imageData -> PromiseKit.Promise<GoogleVisionApiAnnotateResponse> in
            let imageRequest = GoogleVisionApiAnnotateRequest.ImageRequest(
                image: .init(content: imageData.base64EncodedString()),
                features: [
                    .init(type: .safeSearchDetection, maxResults: 10)
                ]
            )
            let visionRequest = GoogleVisionApiAnnotateRequest(requests: [imageRequest])

            return GoogleVisionApi(apiKey: self.apiKey).annotate(request: visionRequest)
        }.done(on: queue) { visionResponse in
            let responses = visionResponse.responses
            guard responses.count > 0, let annotaion = responses[0].safeSearchAnnotation else {
                // TODO: Something went wrong with the vision api request or we have no assumptions. Inform the user...

                let text = "This image is completely safe."
                let replyMessageId = self.message.replyToMessage?.messageId
                let m = TelegramSendMessage(chatId: chatId, text: text, parseMode: .markdown, replyToMessageId: replyMessageId)

                sendApi.sendMessage(message: m)
                return
            }

            let text = self.generateResponse(annotation: annotaion)
            let replyMessageId = self.message.replyToMessage?.messageId
            let m = TelegramSendMessage(chatId: chatId, text: text, parseMode: .markdown, replyToMessageId: replyMessageId)

            sendApi.sendMessage(message: m)
        }.catch(on: queue) { err in
            print("*** ERROR")
            print(err)
        }
    }

    private func generateResponse(annotation: GoogleVisionApiAnnotateResponse.AnnotateImageResponse.SafeSearchAnnotation) -> String {
        var response = "*SAFETY ANALYSIS*"

        response += "\n\nThis image was analyzed. Kindly read my safety report below"

        var warnings = 5

        switch annotation.adult {
        case .unlikely:
            response += "\n\n• It seems like this image MAY contain some nudity, pornographic images or cartoons, or sexual activities. Take care of yourself!"
        case .possible:
            response += "\n\n• Apparently this image COULD contain nudity, pornographic images or cartoons, or sexual activities. Play responsible!"
        case .likely:
            response += "\n\n• It seems LIKELY that this image contains nudity, pornographic images or cartoons, or sexual activities. You better stop this ungodly behaviour!"
        case .veryLikely:
            response += "\n\n• I am sure as hell that this image contains nudity, pornographic images or cartoons, or sexual activities. You may stop this ungodly behaviour right now!"
        default:
            warnings -= 1
        }

        switch annotation.spoof {
        case .unlikely:
            response += "\n\n• It seems like this image MAY have been modified to make it appear funny or offensive. Take care of yourself!"
        case .possible:
            response += "\n\n• Apparently this image COULD have been modified to make it appear funny or offensive. Play responsible!"
        case .likely:
            response += "\n\n• It seems LIKELY that this image has been modified to make it appear funny or offensive. You better stop this ungodly behaviour!"
        case .veryLikely:
            response += "\n\n• I am sure as hell that this image has been modified to make it appear funny or offensive. You may stop this ungodly behaviour right now!"
        default:
            warnings -= 1
        }

        switch annotation.medical {
        case .unlikely:
            response += "\n\n• It seems like this image MAY be a medical image. Take care of yourself! (this is no medical advice)"
        case .possible:
            response += "\n\n• Apparently this image COULD be a medical image. Play responsible! (this is no medical advice)"
        case .likely:
            response += "\n\n• It seems LIKELY that this image is a medical image. You better stop this ungodly behaviour! (this is no medical advice)"
        case .veryLikely:
            response += "\n\n• I am sure as hell that this image is a medical image. You may stop this ungodly behaviour right now! (this is no medical advice)"
        default:
            warnings -= 1
        }

        switch annotation.violence {
        case .unlikely:
            response += "\n\n• It seems like this image MAY contain violent content. Take care of yourself!"
        case .possible:
            response += "\n\n• Apparently this image COULD contain violent content. Play responsible!"
        case .likely:
            response += "\n\n• It seems LIKELY that this image contains violent content. You better stop this ungodly behaviour!"
        case .veryLikely:
            response += "\n\n• I am sure as hell that this image contains violent content. You may stop this ungodly behaviour right now!"
        default:
            warnings -= 1
        }

        switch annotation.racy {
        case .unlikely:
            response += "\n\n• It seems like this image MAY include (not limited to) skimpy or sheer clothing, strategically covered nudity, lewd or provocative poses, or close-ups of sensitive body areas. Take care of yourself!"
        case .possible:
            response += "\n\n• Apparently this image COULD include (not limited to) skimpy or sheer clothing, strategically covered nudity, lewd or provocative poses, or close-ups of sensitive body areas. Play responsible!"
        case .likely:
            response += "\n\n• It seems LIKELY that this image includes (not limited to) skimpy or sheer clothing, strategically covered nudity, lewd or provocative poses, or close-ups of sensitive body areas. You better stop this ungodly behaviour!"
        case .veryLikely:
            response += "\n\n• I am sure as hell that this image includes (not limited to) skimpy or sheer clothing, strategically covered nudity, lewd or provocative poses, or close-ups of sensitive body areas. You may stop this ungodly behaviour right now!"
        default:
            warnings -= 1
        }

        let warnText = warnings == 1 ? "warning" : "warnings"
        let safeOrNot = warnings == 0 ? "So it is considered completely safe." : ""
        response += "\n\nThis image contains on total *\(warnings)* \(warnText). \(safeOrNot)"

        return response
    }
}
