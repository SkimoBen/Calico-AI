//
//  CerebriumCustomSD.swift
//  Calico AI
//
//  Created by Ben Pearman on 2023-06-09.
//MARK: NOT IN USE

import Foundation
import SwiftUI


var cerebriumJSONObject_customSD: [String: Any] = [
    "prompt": "\(positivePrompt)",
   // "model": "\(model)",
    //"image": "\(base64ImageString)",
    //"file_url": "https://github.com/SkimoBen/Photos/blob/ef2a2e52bb2ceb6923bedd11bc02c226902b33b5/leaves.jpg?raw=true",
    //"hf_token": "<your_token>",
   // "model_id": "prompthero/openjourney-v4",
    "height": imageHeight,
    "width": imageWidth,
    "num_inference_steps": samples,
    //"guidance_scale": guidance,
    //"num_images_per_prompt": 4,
   // "negative_prompt": "\(negativePrompt)",
   // "seed": seed,
    //"low_threshold": 100,
    //"high_threshold": 200,
    //"image_resolution": 512
    
]

var prompt_customSD: String = "" {
    didSet {
        updateCerebriumJSONObject_customSD()
    }
}

func updateCerebriumJSONObject_customSD() {
   
    cerebriumJSONObject_customSD["prompt"] = positivePrompt
    
    cerebriumJSONObject_customSD["height"] = imageHeight
    cerebriumJSONObject_customSD["width"] = imageWidth
    cerebriumJSONObject_customSD["num_inference_steps"] = samples
    
    print("updated Cerebrium JSON Object")
    print(cerebriumJSONObject_customSD)
}

//format the dictionary body into proper json for the HTTP request.
func makeJsonPayload_customSD(cerebriumJSONObject_customSD: [String: Any]) -> Data {
    //print("this is the jsonObject inside makeJsonPayload: \(openAiJsonObject)")
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: cerebriumJSONObject_customSD, options: .prettyPrinted)
        // jsonData is now the valid JSON payload
        
        
        return jsonData
    } catch {
        print("Error creating JSON payload: \(error)")
        return Data()
    }
    
}


func sendIt_customSD(completion: @escaping (UIImage?) -> Void, failure: @escaping (String) -> Void) {
    let decoder = JSONDecoder()

    guard let url = URL(string: "https://run.cerebrium.ai/v1/p-2f24fdd5/customsd/predict") else {
        return
    }

    //API Key for customCtrlNet public-bbf531a4a3bd3748f814
    //API Key for prebuilt ControlNet public-4cd3d7e4bcc266780ffd
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("public-bbf531a4a3bd3748f814", forHTTPHeaderField:"Authorization")
    request.addValue("application/json", forHTTPHeaderField:"Content-Type")
    request.httpBody = makeJsonPayload_customSD(cerebriumJSONObject_customSD: cerebriumJSONObject_customSD)
    request.timeoutInterval = 1000

    URLSession.shared.dataTask(with: request) { (data, response, error) in
        guard error == nil else {
            print(error!.localizedDescription)
            DispatchQueue.main.async {
                failure("Failed due to error: \(error!.localizedDescription)")
            }
            return
        }
        
        //for debugging the bad data
        if let data = data {
            print(String(data: data, encoding: .utf8) ?? "Failed to convert data to string")
        } else {
            print("Data is nil")
        }
        
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
