//
//  UserImageView.swift
//  Calico AI
//
//  Created by Ben Pearman on 2023-06-09.
//

import SwiftUI

struct UserImageView: View {
    @EnvironmentObject var viewModel: ViewModelClass
    var body: some View {
        VStack {
            Spacer()
            
            if viewModel.background != nil {
                
                Image(uiImage: viewModel.background!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Image(systemName: "questionmark.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .opacity(0.0)
            }
            
            Spacer()
        }
    }
}

struct UserImageView_Previews: PreviewProvider {
    static var previews: some View {
        UserImageView()
            .environmentObject(ViewModelClass())
    }
}
