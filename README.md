# watson-insight
iOS Swift app using the iOS Watson SDK to provide cognitive insights on image, voice and document content.

## Overview
A user can enter a content to analyze in 4 different ways:
* Take a photo or chose one in the gallery. The `Visual Recognition API` is used to run a classification, detect faces and extract text.
* Use the iPhone microphone. The `Speech To Text API` generates a transcription. 
* Chose a Word or PDF document. The `Document Conversion API` extracts the content in a plain text. 
* Compose or copy-paste some plain text. 

Once the text content is entered, it can be spoken through the `Text To Speech API` and a list of analysis executed on it. Currently you can
* Analyze the tone of the text with the `Tone Analyzer API`
* Analyze the personality for content with more than 100 words with the `Personality Insights API`

## Watson APIs used
- Visual Recognition V3
- Speech To Text V1
- Text To Speech V1
- Document Conversion V1
- Tone Analyzer V3
- Personality Insights V2

## Setup
The project is using the Watson iOS SDK which in its turn uses Carthage to manage dependencies.

1. Checkout or clone the repository
2. Navigate to the project root folder and run `$carthage update --platform iOS`
3. Fill the `BluemixAccess.plist` file with your credentials to access the Watson services.
4. Compile and run


## Improvements
The structure of the project allows to add easily additional analysis on a text. The AnalysisSelection view controller contains the list of the services that can be processed. Further coming is:
- Alchemy Language
- Language Translator
