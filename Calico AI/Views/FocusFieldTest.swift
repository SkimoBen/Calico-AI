//
//  FocusFieldTest.swift
//  Calico AI
//
//  Created by Ben Pearman on 2023-06-09.
//

import SwiftUI

struct FocusFieldTest: View {
    @State var testText: String = ""
    @FocusState var yesFocus: Bool
    @State var fieldText: String = ""
    @State var showEditor = false
    var body: some View {
        NavigationView {
            VStack {
                
                 if !showEditor {
                     Group {
                        TextEditor(text: $testText)
                            .id("swag")
                            .focused($yesFocus)
                            .frame(minHeight: 100)
                            //.background(.blue)
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                            .padding([.leading, .trailing], 20)
                     }
                     //.transition(.asymmetric(insertion: .opacity, removal: .slide))
                     
                 } else {
                     EmptyView()
                 }
                
                Group {
                    TextField("testText", text: $fieldText) { isEditing in
                        withAnimation {
                            self.showEditor = isEditing
                        }
                    } onCommit: {}
                        .cornerRadius(4)
                    
                    
                        .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.gray, lineWidth: 0.5))
                        .keyboardType(.numberPad)
                }
                .padding(30)
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    Button("Done") {
                        //focusedField = nil
                        yesFocus = false
                        UIApplication.shared.endEditing()
                    }
                }
            }
            
        }
    }
}

struct FocusFieldTest_Previews: PreviewProvider {
    static var previews: some View {
        FocusFieldTest()
    }
}
