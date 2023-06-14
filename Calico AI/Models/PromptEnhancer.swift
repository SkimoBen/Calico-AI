//
//  PromptEnhancer.swift
//  Calico AI
//
//  Created by Ben Pearman on 2023-06-13.
//

import Foundation


var cerebriumPromptEnhancerJSONObject: [String: Any] = [
    "prompt": "\(positivePrompt)"
]

func updateCerebriumPromptEnhancerJSONObject() {
    cerebriumPromptEnhancerJSONObject["prompt"] = positivePrompt
}

func EnhancePrompt(viewModel: ViewModelClass, completion: @escaping () -> Void) {
    let decoder = JSONDecoder()
    
    guard let url = URL(string: "https://run.cerebrium.ai/v2/p-2f24fdd5/promptenhancer/predict") else {
        return
    }
    
    //API Key for customCtrlNet public-bbf531a4a3bd3748f814
    //API Key for prebuilt ControlNet public-4cd3d7e4bcc266780ffd
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("public-bbf531a4a3bd3748f814", forHTTPHeaderField:"Authorization")
    request.addValue("application/json", forHTTPHeaderField:"Content-Type")
    request.httpBody = makeJsonPayload(cerebriumJSONObject: cerebriumPromptEnhancerJSONObject)
    request.timeoutInterval = 240
    
    print("legooooo")
    URLSession.shared.dataTask(with: request) { (data, response, error) in
        guard error == nil else {
            print(error!.localizedDescription)
            return
        }
        
        
        guard let data = data else {
            print("Empty data")
            return
        }
        
        do {
            let DecodedData = try decoder.decode(CerebriumPromptEnhancerResponse.self, from: data)
            print("we r decoding ze data baby")
            DecodedData.enhancedPrompt.forEach { prompt in
                DispatchQueue.main.async {
                    viewModel.enhancedPrompt = prompt
                    print(prompt)
                    completion()
                }
                
                
                return
            }
            
        } catch {
            print("Error decoding JSON: \(error)")

        }
    }.resume()
}


struct CerebriumPromptEnhancerResponse: Codable {
    let runID: String
    let message: String
    let runTimeMs: Double
    let enhancedPrompt: [String]
    
    enum CodingKeys: String, CodingKey {
        case runID = "run_id"
        case message = "message"
        case runTimeMs = "run_time_ms"
        case enhancedPrompt = "result"
    }
}
