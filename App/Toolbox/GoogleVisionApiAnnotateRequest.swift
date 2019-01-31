//
//  GoogleVisionApiAnnotateRequest.swift
//  App
//
//  Created by Koray Koska on 14.01.19.
//

import Foundation

struct GoogleVisionApiAnnotateRequest: Codable {

    /// Individual image annotation requests for this batch.
    let requests: [ImageRequest]

    init(requests: [ImageRequest]) {
        self.requests = requests
    }

    struct ImageRequest: Codable {

        /// The image to be processed.
        let image: Image

        /// Requested features.
        let features: [Feature]

        /// Additional context that may accompany the image.
        let imageContext: [ImageContext]?

        init(image: Image, features: [Feature], imageContext: [ImageContext]? = nil) {
            self.image = image
            self.features = features
            self.imageContext = imageContext
        }

        struct Image: Codable {

            /**
             * Image content, represented as a stream of bytes. Note: As with all bytes fields, protobuffers use a pure binary representation, whereas JSON representations use base64.
             * A base64-encoded string.
             */
            let content: String?

            /**
             * Google Cloud Storage image location, or publicly-accessible image URL. If both content and source are provided for an image, content takes precedence and is used to perform the image annotation request.
             */
            let source: ImageSource?

            init(content: String) {
                self.content = content
                self.source = nil
            }

            init(source: ImageSource) {
                self.source = source
                self.content = nil
            }

            struct ImageSource: Codable {

                /**
                 * The URI of the source image. Can be either:
                 *
                 * 1. A Google Cloud Storage URI of the form gs://bucket_name/object_name. Object versioning is not supported. See Google Cloud Storage Request URIs for more info.
                 *
                 * 2. A publicly-accessible image HTTP/HTTPS URL. When fetching images from HTTP/HTTPS URLs, Google cannot guarantee that the request will be completed. Your request may fail if the specified host denies the request (e.g. due to request throttling or DOS prevention), or if Google throttles requests to the site for abuse prevention. You should not depend on externally-hosted images for production applications.
                 *
                 */
                let imageUri: String

                init(imageUri: String) {
                    self.imageUri = imageUri
                }
            }
        }

        struct Feature: Codable {

            /// The feature type.
            let type: FeatureType

            /// Maximum number of results of this type. Does not apply to TEXT_DETECTION, DOCUMENT_TEXT_DETECTION, or CROP_HINTS.
            let maxResults: Int?

            /// Model to use for the feature.
            let model: Model?

            init(type: FeatureType, maxResults: Int? = nil, model: Model? = nil) {
                self.type = type
                self.maxResults = maxResults
                self.model = model
            }

            enum FeatureType: String, Codable {

                /// Unspecified feature type.
                case unspecified = "TYPE_UNSPECIFIED"

                /// Run face detection.
                case faceDetection = "FACE_DETECTION"

                /// Run landmark detection.
                case landmarkDetection = "LANDMARK_DETECTION"

                /// Run logo detection.
                case logoDetection = "LOGO_DETECTION"

                /// Run label detection.
                case labelDetection = "LABEL_DETECTION"

                /// Run text detection / optical character recognition (OCR). Text detection is optimized for areas of text within a larger image; if the image is a document, use DOCUMENT_TEXT_DETECTION instead.
                case textDetection = "TEXT_DETECTION"

                /// Run dense text document OCR. Takes precedence when both DOCUMENT_TEXT_DETECTION and TEXT_DETECTION are present.
                case documentTextDetection = "DOCUMENT_TEXT_DETECTION"

                /// Run Safe Search to detect potentially unsafe or undesirable content.
                case safeSearchDetection = "SAFE_SEARCH_DETECTION"

                /// Compute a set of image properties, such as the image's dominant colors.
                case imageProperties = "IMAGE_PROPERTIES"

                /// Run crop hints.
                case cropHints = "CROP_HINTS"

                /// Run web detection.
                case webDetection = "WEB_DETECTION"

                /// Run localizer for object detection.
                case objectLocalization = "OBJECT_LOCALIZATION"
            }

            enum Model: String, Codable {

                case stable = "builtin/stable"

                case latest = "builtin/latest"
            }
        }

        struct ImageContext: Codable {

            /// Not used.
            let latLongRect: LatLongRect?

            /// List of languages to use for TEXT_DETECTION. In most cases, an empty value yields the best results since it enables automatic language detection. For languages based on the Latin alphabet, setting languageHints is not needed. In rare cases, when the language of the text in the image is known, setting a hint will help get better results (although it will be a significant hindrance if the hint is wrong). Text detection returns an error if one or more of the specified languages is not one of the supported [languages](https://cloud.google.com/vision/docs/languages).
            let languageHints: [String]

            /// Parameters for crop hints annotation request.
            let cropHintsParams: CropHintsParams?

            /// Parameters for web detection.
            let webDetectionParams: WebDetectionParams?

            init(languageHints: [String] = [], cropHintsParams: CropHintsParams? = nil, webDetectionParams: WebDetectionParams? = nil) {
                // Currently not used
                self.latLongRect = nil

                self.languageHints = languageHints
                self.cropHintsParams = cropHintsParams
                self.webDetectionParams = webDetectionParams
            }

            struct LatLongRect: Codable {

                /// Min lat/long pair.
                let minLatLng: LatLng

                /// Max lat/long pair.
                let maxLatLng: LatLng

                init(minLatLng: LatLng, maxLatLng: LatLng) {
                    self.minLatLng = minLatLng
                    self.maxLatLng = maxLatLng
                }

                struct LatLng: Codable {

                    /// The latitude in degrees. It must be in the range [-90.0, +90.0].
                    let latitude: Double

                    /// The longitude in degrees. It must be in the range [-180.0, +180.0].
                    let longitude: Double

                    init(latitude: Double, longitude: Double) {
                        self.latitude = latitude
                        self.longitude = longitude
                    }
                }
            }

            struct CropHintsParams: Codable {

                /// Aspect ratios in floats, representing the ratio of the width to the height of the image. For example, if the desired aspect ratio is 4/3, the corresponding float value should be 1.33333. If not specified, the best possible crop is returned. The number of provided aspect ratios is limited to a maximum of 16; any aspect ratios provided after the 16th are ignored.
                let aspectRatios: [Double]

                init(aspectRatios: [Double]) {
                    self.aspectRatios = aspectRatios
                }
            }

            struct WebDetectionParams: Codable {

                /// Whether to include results derived from the geo information in the image.
                let includeGeoResults: Bool

                init(includeGeoResults: Bool) {
                    self.includeGeoResults = includeGeoResults
                }
            }
        }
    }
}
