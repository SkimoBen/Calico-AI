//
//  PromptEnhancerTest.swift
//  Calico AI
//
//  Created by Ben Pearman on 2023-06-13.
//

import SwiftUI

struct PromptEnhancerTest: View {
    var body: some View {
        Button(action: {
            trigger()
        }, label: {
            Text("Fire the cannons")
        })
    }
}

let model = promptEnhancer(strategy: .topK(40))

let prompt = "Hugging Face is a company that releases awesome projects in machine learning because"

func trigger() {
    DispatchQueue.global(qos: .userInitiated).async {
        model.generate(text: prompt, nTokens: 50) { completion, time in
            DispatchQueue.main.async {
                var startingTxt = prompt
                var completeTxt = completion
                
                print(completion)
                startingTxt.append(completeTxt)
                print(startingTxt)
            }
        }
    }
}


struct PromptEnhancerTest_Previews: PreviewProvider {
    static var previews: some View {
        PromptEnhancerTest()
    }
}
