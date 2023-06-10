//
//  Cerebrium.swift
//  Calico AI
//
//  Created by Ben Pearman on 2023-06-09.
//

import Foundation
import UIKit
import SwiftUI

//make the body of the HTTP request for the cerebrium API. This is in dictionary format.

//need em
var positivePrompt = ""
var negativePrompt = ""
var imageHeight = 512
var imageWidth = 512
var samples = 30
var guidance = 7.5
var seed = 0


//runwayml/stable-diffusion-v1-5
//prompthero/openjourney
var cerebriumJSONObject: [String: Any] = [
    "prompt": "\(positivePrompt)",
    "base64Image": "\(base64ImageString)",
    //"file_url": "https://github.com/SkimoBen/Photos/blob/ef2a2e52bb2ceb6923bedd11bc02c226902b33b5/leaves.jpg?raw=true",
    //"hf_token": "<your_token>",
    "model_id": "prompthero/openjourney-v4",
    "height": imageHeight,
    "width": imageWidth,
    "num_inference_steps": samples,
    "guidance_scale": guidance,
    "num_images_per_prompt": 1,
    "negative_prompt": "\(negativePrompt)",
    "seed": seed,
    "low_threshold": 100,
    "high_threshold": 200,
    //"image_resolution": 512
    "preProcessor": "text2img",
    
    
]

//var cerebriumTestObject: [String: Any] = [
//    "prompt": "\(positivePrompt)",
//    "height": 728,
//    "width": 512,
//    "num_inference_steps": samples,
//    "guidance_scale": guidance,
//    "num_images_per_prompt": 4,
//    "negative_prompt": "\(negativePrompt)",
//    "seed": seed,
//]

//need both of these to update the JSON object since I don't make a base64img when I have a blank canvas.
var preProcessor: String = "text2img" {
    didSet {
        updateCerebriumJSONObject()
  
    }
}
var base64ImageString: String = "" {
    didSet {
        updateCerebriumJSONObject()
        
    }
}

//func updateCerebriumTestObject() {
//    cerebriumTestObject["prompt"] = positivePrompt
//    cerebriumTestObject["negative_prompt"] = negativePrompt
//    cerebriumTestObject["height"] = closestMultipleOfEight(Double(imageHeight))
//    cerebriumTestObject["width"] = closestMultipleOfEight(Double(imageWidth))
//    cerebriumTestObject["num_inference_steps"] = samples
//    cerebriumTestObject["guidance_scale"] = guidance
//    cerebriumTestObject["seed"] = seed
//    print("updated Cerebrium TEST Object")
//    print(cerebriumTestObject)
//}

func updateCerebriumJSONObject() {
    cerebriumJSONObject["base64Image"] = base64ImageString
    cerebriumJSONObject["prompt"] = positivePrompt
    cerebriumJSONObject["negative_prompt"] = negativePrompt
    cerebriumJSONObject["height"] = closestMultipleOfEight(Double(imageHeight))
    cerebriumJSONObject["width"] = closestMultipleOfEight(Double(imageWidth))
    cerebriumJSONObject["num_inference_steps"] = samples
    cerebriumJSONObject["guidance_scale"] = guidance
    cerebriumJSONObject["seed"] = seed
    cerebriumJSONObject["preProcessor"] = preProcessor
   // print("updated Cerebrium JSON Object")
   // print(cerebriumJSONObject)
}

//format the dictionary body into proper json for the HTTP request.
func makeJsonPayload(cerebriumJSONObject: [String: Any]) -> Data {
    //print("this is the jsonObject inside makeJsonPayload: \(openAiJsonObject)")
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: cerebriumJSONObject, options: .prettyPrinted)
        // jsonData is now the valid JSON payload
        
        
        return jsonData
    } catch {
        print("Error creating JSON payload: \(error)")
        return Data()
    }
    
}

//"https://run.cerebrium.ai/v2/p-2f24fdd5/customctrlnetv2/predict"

//gpt sendit:

func sendIt(completion: @escaping (UIImage?) -> Void, failure: @escaping (String) -> Void) {
    let decoder = JSONDecoder()

    guard let url = URL(string: "https://run.cerebrium.ai/v2/p-2f24fdd5/customctrlnetv2/predict") else {
        return
    }

    //API Key for customCtrlNet public-bbf531a4a3bd3748f814
    //API Key for prebuilt ControlNet public-4cd3d7e4bcc266780ffd
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("public-bbf531a4a3bd3748f814", forHTTPHeaderField:"Authorization")
    request.addValue("application/json", forHTTPHeaderField:"Content-Type")
    request.httpBody = makeJsonPayload(cerebriumJSONObject: cerebriumJSONObject)
    request.timeoutInterval = 240

    URLSession.shared.dataTask(with: request) { (data, response, error) in
        guard error == nil else {
            print(error!.localizedDescription)
            DispatchQueue.main.async {
                failure("Failed due to error: \(error!.localizedDescription)")
            }
            return
        }
        
        //for debugging the bad data
//        if let data = data {
//            print(String(data: data, encoding: .utf8) ?? "Failed to convert data to string")
//        } else {
//            print("Data is nil")
//        }
        
        guard let data = data else {
            print("Empty data")
            DispatchQueue.main.async {
                failure("Failed due to empty data.")
            }
            return
        }

        do {
            let DecodedData = try decoder.decode(CerebriumResponse.self, from: data)

            DecodedData.image.forEach { base64ImageString in
                guard let base64ImageData = Data(base64Encoded: base64ImageString) else {
                    print("Error decoding base64 image string")
                    DispatchQueue.main.async {
                        failure("Failed due to error decoding base64 image string.")
                    }
                    return
                }

                guard let processedImage = UIImage(data: base64ImageData) else {
                    print("Error creating UIImage from data")
                    DispatchQueue.main.async {
                        failure("Failed due to error creating UIImage from data.")
                    }
                    return
                }

                UIImageWriteToSavedPhotosAlbum(processedImage, nil, nil, nil)

                DispatchQueue.main.async {
                    completion(processedImage)
                    print("image saved to photos")
                }
            }
        } catch {
            print("Error decoding JSON: \(error)")
            
            DispatchQueue.main.async {
                failure("Failed due to error decoding JSON: \(error.localizedDescription)")
            }
        }
    }.resume()
}



struct CerebriumResponse: Codable {
    let runID: String
    let message: String
    let runTimeMs: Double
    let image: [String]
    
    enum CodingKeys: String, CodingKey {
        case runID = "run_id"
        case message = "message"
        case runTimeMs = "run_time_ms"
        case image = "result"
    }
}

//old sendit
/*
func sendIt(completion: @escaping (UIImage?) -> Void) {
    let decoder = JSONDecoder()
    

    //make the url for the call
    guard let url = URL(string: "https://run.cerebrium.ai/controlnet-webhook/predict")
    else {
        return
    }
    
    //this stuff formats the API call. Cerebrium takes curl requests but swift uses URLRequest. This formats the HTTP request properly
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("public-4cd3d7e4bcc266780ffd", forHTTPHeaderField:"Authorization")
    request.addValue("application/json", forHTTPHeaderField:"Content-Type")
    request.httpBody = makeJsonPayload(cerebriumJSONObject: cerebriumJSONObject)
    request.timeoutInterval = 1000
    print(cerebriumJSONObject["prompt"]as Any)
    print(cerebriumJSONObject["model"] as Any)
    print("starting url session")
    //start the URL session to make the call
    URLSession.shared.dataTask(with: request) { (data, response, error) in
        guard error == nil else { print(error!.localizedDescription); return }
        guard let data = data else { print("Empty data"); return
            
        }
        
        do {
            //get the data out of the JSON object
            let DecodedData = try decoder.decode(CerebriumResponse.self, from: data)
            
            //retrieve the base64 string then turn it into data
            
            DecodedData.image.forEach { base64ImageString in
                guard let base64ImageData = Data(base64Encoded: base64ImageString) else {
                    print("Error decoding base64 image string")
                    return
                }
                
                guard let processedImage = UIImage(data: base64ImageData) else {
                    print("Error creating UIImage from data")
                    return
                }
                print(DecodedData.message)
                // Save the UIImage to photos
                UIImageWriteToSavedPhotosAlbum(processedImage, nil, nil, nil)
                
                DispatchQueue.main.async {
                    completion(processedImage)
                    // Do something to update the UI
                    print("image saved to photos")
                }
            }
            
        } catch {
            print("Error decoding JSON: \(error)")
            print("Json Response: \(String(describing: response))")
            
            DispatchQueue.main.async {
                // Call the completion handler with nil to indicate failure
                completion(nil)
            }
        }
        
    }.resume()
}
 */

//JSON Codable structure for the Cerebrium API response





