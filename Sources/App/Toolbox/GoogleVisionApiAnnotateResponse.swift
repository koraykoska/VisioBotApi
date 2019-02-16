//
//  GoogleVisionApiAnnotateResponse.swift
//  App
//
//  Created by Koray Koska on 30.01.19.
//

import Foundation

struct GoogleVisionApiAnnotateResponse: Codable {

    let responses: [AnnotateImageResponse]

    struct AnnotateImageResponse: Codable {

        let faceAnnotations: [FaceAnnotation]?

        let labelAnnotations: [EntityAnnotation]?

        let safeSearchAnnotation: SafeSearchAnnotation?

        enum Likelihood: String, Codable {

            case unknown = "UNKNOWN"

            case veryUnlikely = "VERY_UNLIKELY"

            case unlikely = "UNLIKELY"

            case possible = "POSSIBLE"

            case likely = "LIKELY"

            case veryLikely = "VERY_LIKELY"
        }

        struct FaceAnnotation: Codable {

            // let boundingPoly: BoundingPoly

            let rollAngle: Double

            let panAngle: Double

            let tiltAngle: Double

            let detectionConfidence: Double

            let landmarkingConfidence: Double

            let joyLikelihood: Likelihood

            let sorrowLikelihood: Likelihood

            let angerLikelihood: Likelihood

            let surpriseLikelihood: Likelihood

            let underExposedLikelihood: Likelihood

            let blurredLikelihood: Likelihood

            let headwearLikelihood: Likelihood
        }

        struct EntityAnnotation: Codable {

            let mid: String

            let locale: String?

            let description: String

            let score: Double

            let topicality: Double
        }

        struct SafeSearchAnnotation: Codable {

            let adult: Likelihood

            let spoof: Likelihood

            let medical: Likelihood

            let violence: Likelihood

            let racy: Likelihood
        }
    }
}
