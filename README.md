# watson-insight
iOS Swift app using the [iOS Watson SDK](https://github.com/watson-developer-cloud/ios-sdk#watson-developer-cloud-ios-sdk) to provide cognitive insights on image, voice and document content.

## Overview
This is a demo iOS Swift app providing some cognitive analysis on content, that can be entered in 4 different ways:
- Take a photo or chose one in the gallery. The `Visual Recognition API` is used to run a classification, detect faces and extract the text to be further analyzed.
- Use the iPhone microphone. The `Speech To Text API` is used to generate a text transcription. 
- Open a Word or PDF document with the app. The `Document Conversion API` is used to convert the content in plain text. 
- Compose or copy-paste some text. 

Once the text content set, it can be spoken through the `Text To Speech API` and processed to
- Analyze the tone with the `Tone Analyzer API`
- Analyze the personality for text with at least 100 words with the `Personality Insights API`

## Requirements
- iOS 9.0+
- Xcode 8.0+
- Swift 2.3

## Watson APIs used
The project uses the following Watson APIs on IBM Bluemix.

- Visual Recognition V3
- Speech To Text V1
- Text To Speech V1
- Document Conversion V1
- Tone Analyzer V3
- Personality Insights V2

You have to deploy these services in the [IBM Bluemix Console](https://console.ng.bluemix.net/) in order to obtain credentials for each of them.

## Setup
The project uses Carthage as this is the tool used to manage the dependencies by the Watson iOS SDK.

1. Checkout or clone this repository
2. Navigate to the project root folder and run `$carthage update --platform iOS`
3. Fill the `BluemixAccess.plist` file with your credentials to access the Watson services.
4. Compile and run

## Contributing
Any contribution to enrich the app with additional Watson cognitive services is welcome.
You can easily extend the project from the `AnalysisSelectionView.swift` which contains the list of the Watson services that can be exectued on the selected text. Language Translator and Alchemy Language are great candidates!
