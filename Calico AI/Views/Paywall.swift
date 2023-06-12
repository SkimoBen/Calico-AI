//
//  Paywall.swift
//  Calico AI
//
//  Created by Ben Pearman on 2023-06-11.
//

import SwiftUI

struct Paywall: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        GeometryReader { geometry in
            
            
            VStack {
                VStack {
                    
                    VStack {
                        Spacer()
                        
                        Package(
                            Tier: "Calico Apprentice",
                            price: "$1.99 per month",
                            Point1: "• 1000 Tokens per month (~350 images)",
                            Point2: "• 720 X 720 Max resolution",
                            Point3: "• Generate 1 image at a time",
                            frameSize: (geometry.size.width * 0.85),
                            buttonColor: colorScheme == .dark ? [.white] : [.black],
                            accentColor: colorScheme == .dark ? [.white] : [.black]
                        )
                        .shadow(radius: 10)
                        Spacer()
                        Package(
                            Tier: "Calico Sorcerer",
                            price: "$9.99 per month",
                            Point1: "• 6500 Tokens per month (~2200 images)",
                            Point2: "• 1024 X 1024 Max resolution",
                            Point3: "• Generate 2 images at a time",
                            frameSize: (geometry.size.width * 0.9),
                            buttonColor: [.mint],
                            accentColor: [.mint]
                        )
                        
                        .shadow(radius: 10)
                        Spacer()
                        Package(
                            Tier: "Calico Illusionist",
                            price: "$24.99 per month",
                            Point1: "• Unlimited generations",
                            Point2: "• 2048 X 2048 Max resolution",
                            Point3: "• Generate 4 images at a time",
                            frameSize: (geometry.size.width * 0.85),
                            buttonColor: colorScheme == .dark ? [.cyan, .blue] : [.cyan, .blue, .blue],
                            accentColor: colorScheme == .dark ? [.cyan, .blue] : [.cyan, .blue, .blue]
                        )
                        .shadow(radius: 10)
                        
                        Spacer()
                    }
                    .frame(maxWidth: 500)
                    
                }
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial.opacity(1.0))
            }
            .frame(maxWidth: .infinity)
            .background(
                AngularGradient(colors: [.cyan, .pink, .white, .red, .blue, .white, .cyan],
                                center: .center,
                                startAngle: Angle(degrees: 0),
                                endAngle: Angle(degrees: 350)
                               ).opacity(0.3)
            )
        }
    }
}


struct Package: View {
    var Tier: String
    var price: String
    var Point1: String
    var Point2: String
    var Point3: String
    var frameSize: CGFloat
    var buttonColor: [Color]
    var accentColor: [Color]
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        VStack {
            //HEADER
            Text(Tier)
                .font(
                    .largeTitle
                    //.system(size: UIFontMetrics.default.scaledValue(for: 24), design: .rounded)
                    //.system(size: 24, design: .rounded)
                    .weight(.regular)
                )
                .foregroundStyle(RadialGradient(colors: accentColor, center: .trailing, startRadius: 0, endRadius: 130))
               // .foregroundStyle(LinearGradient(colors: accentColor, startPoint: .leading, endPoint: .trailing))
                .padding(2)
            
            
            //POINTS
            VStack(alignment: .leading) {
                Text(Point1)
                    .font(
                        .body
                        .weight(.light)
                        
                    )
                    
  
                Text(Point2)
                    .font(
                        .body
                        //.system(.body, design: .rounded)
                        .weight(.light)
                    )
                    
                Text(Point3)
                    .font(
                        .body
                        //.system(.body, design: .rounded)
                        .weight(.light)
                    )
            }
           // .frame(width: frameSize * 0.9, height: 90)
            .padding(.leading, 2)
            .padding(.trailing, 2)
            //.overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(borderColor), lineWidth: 2))
            
            //PRICE
            Text(price)
                .font(
                    .callout
                    //.system(size: 24, design: .rounded)
                    .weight(.medium)
                )
                .padding(.top, 2)
            
            //SUBSCRIBE BUTTON
            Button(action: {
                
            }, label: {
                Text("Subscribe")
                    .padding(5)
                    .foregroundColor(colorScheme == .dark ? .black : .white)
                    .frame(maxWidth: 200)
            })
            
            .background(RadialGradient(colors: buttonColor, center: .trailing, startRadius: 0, endRadius: 130))
            .clipShape(Capsule())
            
            
        }//END of VStack
        .padding(8)
        .frame(maxWidth: frameSize )
        
        .background(.thinMaterial)
        .cornerRadius(10)
        //.overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(borderColor), lineWidth: 2))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(LinearGradient(colors: accentColor, startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2))
    }
}

struct Paywall_Previews: PreviewProvider {
    static var previews: some View {
        Paywall()
    }
}
