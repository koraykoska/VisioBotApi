//
//  SentimentCommand.swift
//  App
//
//  Created by Koray Koska on 15.02.19.
//

import Vapor
import TelegramBot
import TelegramBotPromiseKit
import PromiseKit

class SentimentCommand: BaseCommand {

    enum Error: Swift.Error {

        case imageDownloadFailed
    }

    static let command: String = "#sentiment"

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

        guard let photos = message.replyToMessage?.photo else {
            // TODO: Send message with expenation how to use the #sentiment command
            return
        }
        let bestPhoto = photos[photos.count - 1]

        let fileId = bestPhoto.fileId

        let sendApi = TelegramSendApi(token: token, provider: SnakeTelegramProvider(token: token))

        let queue = DispatchQueue(label: "SnedApi")

        sendApi.getFile(fileId: fileId).then(on: queue) { file in
            return ImageDownloader.downloadImage(url: "https://api.telegram.org/file/bot\(self.token)/\(file.filePath ?? "")")
        }.then(on: queue) { imageData -> PromiseKit.Promise<GoogleVisionApiAnnotateResponse> in
            let imageRequest = GoogleVisionApiAnnotateRequest.ImageRequest(
                image: .init(content: imageData.base64EncodedString()),
                features: [
                    .init(type: .faceDetection, maxResults: 10)
                ]
            )
            let visionRequest = GoogleVisionApiAnnotateRequest(requests: [imageRequest])

            return GoogleVisionApi(apiKey: self.apiKey).annotate(request: visionRequest)
        }.done(on: queue) { visionResponse in
            let responses = visionResponse.responses
            guard responses.count > 0, let annotaions = responses[0].faceAnnotations else {
                // TODO: Something went wrong with the vision api request or we have no assumptions. Inform the user...

                let text = "This is not a face."
                let replyMessageId = self.message.replyToMessage?.messageId
                let m = TelegramSendMessage(chatId: chatId, text: text, parseMode: .markdown, replyToMessageId: replyMessageId)

                sendApi.sendMessage(message: m)
                return
            }

            let text = self.generateResponse(annotations: annotaions)
            let replyMessageId = self.message.replyToMessage?.messageId
            let m = TelegramSendMessage(chatId: chatId, text: text, parseMode: .markdown, replyToMessageId: replyMessageId)

            sendApi.sendMessage(message: m)
        }.catch(on: queue) { err in
            print("*** ERROR")
            print(err)
        }
    }

    private func generateResponse(annotations: [GoogleVisionApiAnnotateResponse.AnnotateImageResponse.FaceAnnotation]) -> String {
        var response = "*SENTIMENT ANALYSIS*"

        let faceText = annotations.count == 1 ? "face" : "faces"
        response += "\n\nI detected \(annotations.count) \(faceText). Kindly read my sentiment report below."

        for a in annotations {
            response += "\n\n_FACE (Confidence: \(Int(a.detectionConfidence * 100)))%:_"

            response += "\nJoy: \(a.joyLikelihood.rawValue.replacingOccurrences(of: "_", with: " "))"
            response += "\nSorrow: \(a.sorrowLikelihood.rawValue.replacingOccurrences(of: "_", with: " "))"
            response += "\nAnger: \(a.angerLikelihood.rawValue.replacingOccurrences(of: "_", with: " "))"
            response += "\nSurprise: \(a.surpriseLikelihood.rawValue.replacingOccurrences(of: "_", with: " "))"
            response += "\nUnderexposed: \(a.underExposedLikelihood.rawValue.replacingOccurrences(of: "_", with: " "))"
            response += "\nBlurred: \(a.blurredLikelihood.rawValue.replacingOccurrences(of: "_", with: " "))"
            response += "\nHeadwear: \(a.headwearLikelihood.rawValue.replacingOccurrences(of: "_", with: " "))"
        }

        return response
    }
}
