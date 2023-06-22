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
            
            Text(userViewModel.currentUserEntitlements.title)
                .foregroundStyle(
                    LinearGradient(colors: userViewModel.currentUserEntitlements.accentColour, startPoint: .leading, endPoint: .trailing)
                )
            
            
            Text("|")
                .foregroundColor(userViewModel.currentUserEntitlements.accentColour[0])
            
            Image("\(userViewModel.currentUserEntitlements.cashPicName)")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 20)
                .foregroundColor(Color.blue)
            
            Text("6500")
                .font(.caption)
                .foregroundColor(userViewModel.currentUserEntitlements.accentColour[0])
            
            
            
            
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
    }
}

struct RightMenuView: View {
    @Binding var showingAlert: Bool
    @Binding var showProfileView: Bool
    var body: some View {
        VStack {
            //Play button for image generation
            Button(action: {
                //Need DispatchQueue for Menu bug
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    showingAlert = true
                }
                
            }, label: {
        
                Image(systemName: "play.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 30)
                    .foregroundStyle(
                        LinearGradient(colors: [.cyan,.blue, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
        
            })
            Spacer()
            
            Button(action: {
                //Need DispatchQueue for Menu bug
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    showProfileView = true
                }
                
            }, label: {
                Image(systemName: "person.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 25)
            })
        }
        .frame(maxHeight: 80)
        .padding()
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
                //this is to solve the menu bug which causes sheets to stop working if tapped when menu is open.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    showPromptView = true
                }
                
            }, label: {
                
                Image(systemName: "slider.horizontal.3")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 30)
                    
                
            })
            .padding(.bottom,10)
            //Pencil menue view for sketch vs image picker
            Menu {
                PencilMenuView(showingAlert: $showingAlert, isImagePickerPresented: $isImagePickerPresented, showPaywallView: $showPaywallView)
            }label: {
                Image(systemName: "pencil.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    
            }
            
        }
        .frame(maxHeight: 80)
        .padding()
        //.overlay(RoundedRectangle(cornerRadius: 30).stroke(Color.gray, lineWidth: 1))
        .background(.ultraThinMaterial.opacity(0.9)) // Adjust the opacity to make the background ultra thin
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .padding(.leading, 20)
    }
}



struct TopBarView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ViewModelClass())
            .environmentObject(UserViewModel())
    }
}
