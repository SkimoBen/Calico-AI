//
//  TopBarView.swift
//  Calico AI
//
//  Created by Ben Pearman on 2023-06-15.
//

import SwiftUI

struct EntitlementsView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    var body: some View {
        HStack {
            VStack {
                Text(userViewModel.currentUserEntitlements.title)
                    .foregroundStyle(
                        LinearGradient(colors: userViewModel.currentUserEntitlements.accentColour, startPoint: .leading, endPoint: .trailing)
                    )
                
                Image(systemName: "c.circle")
            }
            
        }
        .padding(8)
        //.overlay(RoundedRectangle(cornerRadius: 30).stroke(Color.gray, lineWidth: 1))
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .padding(.bottom, 100)
        
        
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

struct RightMenuView: View {
    @Binding var showingAlert: Bool
    var body: some View {
        VStack {
            //Play button for image generation
            Button(action: {
                
                showingAlert = true
            }, label: {
        
                Image(systemName: "play.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    
        
            })
            
            StatusView()
        }
        .padding()
        //.overlay(RoundedRectangle(cornerRadius: 30).stroke(Color.gray, lineWidth: 1))
        .background(.ultraThinMaterial.opacity(0.9)) 
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .padding(.trailing, 20)
    }
}

struct EditorsButtonsView: View {
    @Binding var showingAlert: Bool
    @Binding var isImagePickerPresented: Bool
    @Binding var showProfileView: Bool
    @Binding var showPaywallView: Bool
    @Binding var showPromptView: Bool
    var body: some View {
        VStack {
            //PromptView button
            Button(action: {
                //isMenuOpen = false
                showPromptView = true
            }, label: {
                
                Image(systemName: "slider.horizontal.3")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 30)
                    
                
            })
            .padding(.bottom,10)
            //Pencil menue view for sketch vs image picker
            Menu {
                PencilMenuView(showingAlert: $showingAlert, isImagePickerPresented: $isImagePickerPresented, showProfileView: $showProfileView, showPaywallView: $showPaywallView)
            }label: {
                Image(systemName: "pencil.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    
            }
            
        }
        .padding()
        //.overlay(RoundedRectangle(cornerRadius: 30).stroke(Color.gray, lineWidth: 1))
        .background(.ultraThinMaterial.opacity(0.9)) // Adjust the opacity to make the background ultra thin
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .padding(.leading, 20)
    }
}

struct StatusView: View {
    var body: some View {
        VStack {
            Text("Trial")
                //.foregroundColor(.black)
                .font(.caption)
            Text("1000")
                //.foregroundColor(.black)
                .font(.caption2)
        }
        
    }
}

struct TopBarView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ViewModelClass())
            .environmentObject(UserViewModel())
    }
}
