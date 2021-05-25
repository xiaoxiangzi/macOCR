//
//  main.swift
//  OCR
//
//  Created by Marcus Schappi on 17/5/21, 11:36 am
//

import Foundation
import CoreImage
import Cocoa
import Vision
import ScreenCapture

let regionUrl = ScreenCapture.captureRegion(destination: "/tmp/ocr.png")

extension String
{
    func trim() -> String
   {
    return self.trimmingCharacters(in: CharacterSet.whitespaces)
   }
}

let EN_LAN = "en-US"
var detectLan = EN_LAN

if CommandLine.arguments.count > 1 {
    detectLan = CommandLine.arguments[1].trim()
}

func convertCIImageToCGImage(inputImage: CIImage) -> CGImage? {
    let context = CIContext(options: nil)
    if let cgImage = context.createCGImage(inputImage, from: inputImage.extent) {
        return cgImage
    }
    return nil
}

func recognizeTextHandler(request: VNRequest, error: Error?) {
    guard let observations =
            request.results as? [VNRecognizedTextObservation] else {
        return
    }
    let recognizedStrings = observations.compactMap { observation in
        // Return the string of the top VNRecognizedText instance.
        return observation.topCandidates(1).first?.string
    }
    
    // Process the recognized strings.
    let joined = recognizedStrings.joined(separator: " ")
    print(joined)
    
    let pasteboard = NSPasteboard.general
    pasteboard.declareTypes([.string], owner: nil)
    pasteboard.setString(joined, forType: .string)
    
}

func detectText(fileName : URL, detectLanguage : String) -> [CIFeature]? {
    if let ciImage = CIImage(contentsOf: fileName){
        guard let img = convertCIImageToCGImage(inputImage: ciImage) else { return nil}
      
        let requestHandler = VNImageRequestHandler(cgImage: img)

        // Create a new request to recognize text.
        let request = VNRecognizeTextRequest(completionHandler: recognizeTextHandler)
        request.usesLanguageCorrection = true
        
        if detectLanguage == EN_LAN {
            request.recognitionLanguages = [EN_LAN]
        } else {
            request.recognitionLanguages = [detectLanguage, EN_LAN]
        }
        
        do {
            // Perform the text-recognition request.
            try requestHandler.perform([request])
        } catch {
            print("Unable to perform the requests: \(error).")
        }
}
    return nil
}

    
    let inputURL = URL(fileURLWithPath: "/tmp/ocr.png")
   
    if let features = detectText(fileName : inputURL, detectLanguage: detectLan), !features.isEmpty{
              
    }
   
 exit(EXIT_SUCCESS)
