//
//  TopBarView.swift
//  Calico AI
//
//  Created by Ben Pearman on 2023-06-15.
//

import SwiftUI

struct TopBarView: View {
    @Binding var showPromptView: Bool
    @EnvironmentObject var viewModel: ViewModelClass
    @Binding var isImagePickerPresented: Bool
    @Binding var showingAlert: Bool
    @Binding var updateView: Bool
    @Binding var showProfileView: Bool
    @Binding var showPaywallView: Bool
    @State private var isMenuOpen = false
    
    var body: some View {
        HStack {

            //PromptView button
            Button(action: {
                //isMenuOpen = false
                showPromptView = true
            }, label: {
        
                Image(systemName: "slider.horizontal.3")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 30)
                    .padding(.leading, 40)
        
            })
            Spacer()
            
            //Play button for image generation
            Button(action: {
                showingAlert = true
            }, label: {
        
                Image(systemName: "play")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 30)
                    .padding(.leading, 15)
        
            })
            
            Spacer()
            //Pencil menue view for sketch vs image picker
            Menu {
                PencilMenuView(showingAlert: $showingAlert, isImagePickerPresented: $isImagePickerPresented, showProfileView: $showProfileView, showPaywallView: $showPaywallView)
            }label: {
                Image(systemName: "pencil.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .padding(.trailing, 40)
            }
           
            
        }
        .background(.white)
    }
}

struct PencilMenuView: View {
    @Binding var showingAlert: Bool
    @EnvironmentObject var viewModel: ViewModelClass
    @Binding var isImagePickerPresented: Bool
    @Binding var showProfileView: Bool
    @Binding var showPaywallView: Bool
    var body: some View {
        //sketch button
        Button(action: {
            withAnimation {
                viewModel.shouldBecomeFirstResponder = true
                viewModel.background = nil
            }
        }, label: {
            HStack {
                Text("Generate image from sketch")
                Image(systemName: "scribble")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
            }

        })
        
        Button(action: {
            //upload a photo from camera roll
            withAnimation {
                viewModel.shouldBecomeFirstResponder = false
                isImagePickerPresented = true
            }
        }, label: {
            HStack {
                Text("Upload your own photo")
                Image(systemName: "photo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
            }
            
        })
        
        //Account info button
        Button(action: {
            showPaywallView = true
        }, label: {
            Text("Account Info")
            Image(systemName: "person.circle")
        })

        
    }
}

struct StatusView: View {
    var body: some View {
        HStack {
            Spacer()
            Spacer()
            Text("Trial")
           
        }
        
    }
}

struct TopBarView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ViewModelClass())
    }
}
