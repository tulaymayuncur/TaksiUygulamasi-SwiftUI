//
//  WelcomeView.swift
//  taksiUygulamasi
//
//  Created by Tülay MAYUNCUR on 15.04.2023.
//



import SwiftUI

struct WelcomeView: View {
    @State private var logoScale: CGFloat = 0.1
    @State private var isActive:Bool = false
    var body: some View {
        if isActive {
            LoginSignUp()
        }else{
            ZStack {
                Color(#colorLiteral(red: 0.9960784314, green: 0.7333333333, blue: 0.1411764706, alpha: 1))
                    .edgesIgnoringSafeArea(.all)
            VStack {
                Image("TaksiUILogo")
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(logoScale)
                    .animation(.easeInOut(duration: 1.0))
                    .onAppear {
                        logoScale = 1.0
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
                           isActive  = true
                        }
                    }
                
         
                }
            }
        }
    }
}


struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        LoginSignUp()
        
    }
}

