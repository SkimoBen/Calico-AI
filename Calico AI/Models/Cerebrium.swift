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
var strength = 0.3
var num_images_per_prompt = 1


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
    "num_images_per_prompt": num_images_per_prompt,
    "negative_prompt": "\(negativePrompt)",
    "seed": seed,
    "low_threshold": 100,
    "high_threshold": 200,
    //"image_resolution": 512
    "preProcessor": "text2img",
    "strength": strength
    
]


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

//Modal endpoints... not used because modal is slow as balls
let txt2img_Endpoint = "https://skimoben--stable-diffusion-cli-entrypoint.modal.run"
let img2img_Endpoint = "https://skimoben--img2img-entrypoint.modal.run"

func updateCerebriumJSONObject() {
    cerebriumJSONObject["base64Image"] = base64ImageString
    cerebriumJSONObject["prompt"] = positivePrompt
    cerebriumJSONObject["negative_prompt"] = negativePrompt
    cerebriumJSONObject["height"] = closestMultipleOfEight(Double(imageHeight))
    cerebriumJSONObject["width"] = closestMultipleOfEight(Double(imageWidth))
    cerebriumJSONObject["num_inference_steps"] = samples
    cerebriumJSONObject["num_images_per_prompt"] = num_images_per_prompt
    cerebriumJSONObject["guidance_scale"] = guidance
    cerebriumJSONObject["seed"] = seed
    cerebriumJSONObject["preProcessor"] = preProcessor
    cerebriumJSONObject["strength"] = strength
   // print("updated Cerebrium JSON Object")
   // print(cerebriumJSONObject)
    
    //switch endpoints
    endPointURL = ChooseEndpoint(preProcessor: preProcessor)
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

//cerebrium part 1: https://run.cerebrium.ai/v2/p-2f24fdd5/cerebriumpart1/predict

var endPointURL: String = "no pls"

func sendIt(completion: @escaping (UIImage?) -> Void, failure: @escaping (String) -> Void) {
    let decoder = JSONDecoder()

    guard let url = URL(string: endPointURL) else {
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
                
                //save the runtime data to user defaults:
                let runTimeHelper = RunTimeHelper()
                var userRunTime = runTimeHelper.getRunTime()
                userRunTime.totalRunTime += DecodedData.runTimeMs / 1000
                userRunTime.monthlyRunTime += DecodedData.runTimeMs / 1000
                runTimeHelper.save(runTime: userRunTime)
                
                DispatchQueue.main.async {
                    completion(processedImage)
                    print("image saved to photos")
                    print("Monthly run time: \(userRunTime.monthlyRunTime)")
                    print("Total run time: \(userRunTime.totalRunTime)")
                    
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







