//
//  BluemixAccess.swift
//  WatsonInsight
//
//  Created by Oleg Ivanov on 16.09.16.
//  Copyright © 2016 IBM. All rights reserved.
//

import Foundation

class BluemixAccess {
	var visualRecognitionKey: String? = nil
	var visualRecognitionVersion: String? = nil

	var speechToTextUsername: String? = nil
	var speechToTextPassword: String? = nil

	var documentConversionUsername: String? = nil
	var documentConversionPassword: String? = nil
	var documentConversionVersion: String? = nil

	var textToSpeechUsername: String? = nil
	var textToSpeechPassword: String? = nil

	var personalityInsightsUsername: String? = nil
	var personalityInsightsPassword: String? = nil

	var toneAnalyzerUsername: String? = nil
	var toneAnalyzerPassword: String? = nil
	var toneAnalyzerVersion: String? = nil

	static private let bluemixAccess = BluemixAccess()

	private init() {
		if let bluemixAccessFilePath = NSBundle.mainBundle().pathForResource("BluemixAccess", ofType: "plist") {
			if let credentials = NSDictionary(contentsOfFile: bluemixAccessFilePath) as? Dictionary<String, String> {
				visualRecognitionKey = credentials["visualRecognitionKey"]!
				visualRecognitionVersion = credentials["visualRecognitionVersion"]!

				speechToTextUsername = credentials["speechToTextUsername"]!
				speechToTextPassword = credentials["speechToTextPassword"]!

				documentConversionUsername = credentials["documentConversionUsername"]!
				documentConversionPassword = credentials["documentConversionPassword"]!
				documentConversionVersion = credentials["documentConversionVersion"]!

				textToSpeechUsername = credentials["textToSpeechUsername"]!
				textToSpeechPassword = credentials["textToSpeechPassword"]!

				personalityInsightsUsername = credentials["personalityInsightsUsername"]!
				personalityInsightsPassword = credentials["personalityInsightsPassword"]!

				toneAnalyzerUsername = credentials["toneAnalyzerUsername"]!
				toneAnalyzerPassword = credentials["toneAnalyzerPassword"]!
				toneAnalyzerVersion = credentials["toneAnalyzerVersion"]!
			}
		}
	}

	static func credentials() -> BluemixAccess {
		return bluemixAccess
	}
}
