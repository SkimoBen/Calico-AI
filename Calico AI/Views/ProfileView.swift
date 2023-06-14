//
//  ProfileView.swift
//  Calico AI
//
//  Created by Ben Pearman on 2023-06-11.
//

import SwiftUI

struct ProfileView: View {
    //Allow the user to dismiss the view
    @Environment(\.dismiss) var dismiss
    @Binding var showProfileView:  Bool
    var body: some View {
        //topbar
        VStack {
            HStack {
                Button("Back") {
                    showProfileView = false
                    dismiss()
                }
                .padding(.leading, 15)
                Spacer()
            }
            .background(Color.clear)
            Spacer()
        }
        
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(showProfileView: .constant(true))
    }
}