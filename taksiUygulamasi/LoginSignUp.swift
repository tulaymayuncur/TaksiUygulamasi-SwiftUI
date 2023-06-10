

import SwiftUI
import Firebase
struct AlertItem: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let dismissAction: (() -> Void)?
}

struct LoginSignUp: View {
    
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    @State private var showRegistrationSuccess = false
    @State private var isLoggedIn = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var showResetPassword = false
    @State private var alertItem: AlertItem?

    var body: some View {
        NavigationView {
            if isLoggedIn {
                ContentView()
            } else if isSignUp {
                SignUpView(email: $email, password: $password, isSignUp: $isSignUp, showRegistrationSuccess: $showRegistrationSuccess, showErrorAlert: $showErrorAlert, errorMessage: $errorMessage,alertItem: $alertItem)
                    .alert(item: $alertItem) { item in
                               Alert(
                                   title: Text(item.title),
                                   message: Text(item.message),
                                   dismissButton: item.dismissAction != nil ? .default(Text("Tamam"), action: item.dismissAction) : .default(Text("Tamam"))
                               )
                           }
            } else {
                LoginView(email: $email, password: $password, isSignUp: $isSignUp, isLoggedIn: $isLoggedIn, showErrorAlert: $showErrorAlert, errorMessage: $errorMessage, showResetPassword: $showResetPassword)
                    .alert(isPresented: $showErrorAlert) {
                        Alert(
                            title: Text("Hata"),
                            message: Text(errorMessage),
                            dismissButton: .default(Text("Tamam"))
                        )
                }
                .sheet(isPresented: $showResetPassword) {
                    ResetPasswordView(email: $email, showResetPassword: $showResetPassword)
                }
            }
        }
    }
}

struct LoginView: View {
    @Binding var email: String
    @Binding var password: String
    @Binding var isSignUp: Bool
    @Binding var isLoggedIn: Bool
    @Binding var showErrorAlert: Bool
    @Binding var errorMessage: String
    @Binding var showResetPassword: Bool

    @State private var navigateToHome = false

    var body: some View {
        ZStack {
            Color(#colorLiteral(red: 0.9960784314, green: 0.7333333333, blue: 0.1411764706, alpha: 1))
                .edgesIgnoringSafeArea(.all)

            VStack {
                Image("TaksiUILogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding()

                Text("Giriş Yap")
                    .font(.largeTitle)
                    .bold()

                TextField("E-posta", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .autocapitalization(.none)

                SecureField("Şifre", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button("Giriş Yap") {
                    login()
                }
                .padding()

                Button("Şifrenizi mi unuttunuz?") {
                    showResetPassword = true
                }
                .padding()

                Spacer()

                Button("Hesabınız yok mu? Kaydolun!") {
                    isSignUp = true
                }
            }
            .padding()
        }
        .background(
            NavigationLink(
                destination: ContentView(),
                isActive: $navigateToHome,
                label: { EmptyView() }
            )
            .isDetailLink(false)
        )
    }

    private func login() {
        if !self.email.isEmpty && !self.password.isEmpty {
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let error = error {
                    // Giriş hatası durumunda yapılacaklar
                    errorMessage = "E-posta veya şifre hatalı. Lütfen tekrar deneyin."
                    showErrorAlert = true
                    print("Giriş hatası: \(error.localizedDescription)")
                } else {
                    // Başarılı giriş durumunda yapılacaklar
                    print("Giriş başarılı")
                    isLoggedIn = true
                    navigateToHome = true // Yönlendirmeyi tetikle
                }
            }
        } else {
            errorMessage = "Lütfen alanları doldurunuz."
            showErrorAlert = true
        }
    }
}

struct SignUpView: View {
    @Binding var email: String
    @Binding var password: String
    @Binding var isSignUp: Bool
    @Binding var showRegistrationSuccess: Bool
    @Binding var showErrorAlert: Bool
    @Binding var errorMessage: String
    @Binding  var alertItem: AlertItem?
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var plate: String = ""
    @State private var confirmPassword = ""
  

    var body: some View {
        ZStack {
            Color(#colorLiteral(red: 0.9960784314, green: 0.7333333333, blue: 0.1411764706, alpha: 1))
                .edgesIgnoringSafeArea(.all)

            VStack {
                Text("Kaydol")
                    .font(.largeTitle)
                    .bold()

                TextField("E-posta", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .autocapitalization(.none)

                TextField("Ad", text: $firstName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                TextField("Soyad", text: $lastName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                TextField("Plaka", text: $plate)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                SecureField("Şifre", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                SecureField("Şifreyi Onayla", text: $confirmPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button("Kaydol") {
                    signUp()
                }
                .padding()

                Spacer()

                Button("Zaten hesabınız var mı? Giriş yapın!") {
                    isSignUp = false
                }
            }
            .padding()
        }
    }

    private func signUp() {
        if password == confirmPassword {
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let error = error {
                    // Kayıt hatası durumunda yapılacaklar
                
                    alertItem = AlertItem(title: "Hata", message: "Kayıt oluşturulurken bir hata oluştu. Lütfen tekrar deneyin.",dismissAction: ({}))
                    
                    showErrorAlert = true
                    print("Kayıt hatası: \(error.localizedDescription)")
                } else {
                    // Başarılı kayıt durumunda yapılacaklar
                    print("Kayıt başarılı")
                    alertItem = AlertItem(title: "Başarılı", message: "Kayıt başarıyla oluşturuldu.",dismissAction: ({isSignUp.toggle()}))
                    fireStoreAddData(result: result!)
                }
            }
        } else {
            // Şifreler uyuşmuyor hatası durumunda yapılacaklar
            
            alertItem = AlertItem(title: "Hata", message: "Şifreler uyuşmuyor. Lütfen tekrar deneyin.",dismissAction: ({}))

        }
    }
    func fireStoreAddData(result:AuthDataResult){
        
        let userData: [String: Any] = ["email": email, "isim":firstName,"soyIsim":lastName,"plaka":plate]
                   
                   // Firestore'a kullanıcı verilerini kaydetme
                   let db = Firestore.firestore()
                   db.collection("users").document(result.user.uid).setData(userData) { error in
                       if let error = error {
                           print("Firestore kaydetme hatası: \(error.localizedDescription)")
                       } else {
                           print("Kullanıcı firebase kaydı başarıyla tamamlandı.")
                       }
                   }
    }
}

struct ResetPasswordView: View {
    @Binding var email: String
    @Binding var showResetPassword: Bool

    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var showPasswordResetSuccess = false

    var body: some View {
        VStack {
            Text("Şifrenizi Sıfırlayın")
                .font(.largeTitle)
                .bold()
                .padding()

            TextField("E-posta", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .autocapitalization(.none)

            Button("Sıfırlama E-postası Gönder") {
                resetPassword()
            }
            .padding()

            Spacer()
        }
        .padding()
        .alert(isPresented: $showErrorAlert) {
            Alert(
                title: Text("Hata"),
                message: Text(errorMessage),
                dismissButton: .default(Text("Tamam"))
            )
        }
        .alert(isPresented: $showPasswordResetSuccess) {
            Alert(
                title: Text("Başarılı"),
                message: Text("Şifre sıfırlama e-postası gönderildi."),
                dismissButton: .default(Text("Tamam")) {
                    showResetPassword = false
                }
            )
        }
    }

    private func resetPassword() {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                // Şifre sıfırlama hatası durumunda yapılacaklar
                errorMessage = "Şifre sıfırlama e-postası gönderilirken bir hata oluştu. Lütfen tekrar deneyin."
                showErrorAlert = true
                print("Şifre sıfırlama hatası: \(error.localizedDescription)")
            } else {
                // Şifre sıfırlama başarılı durumunda yapılacaklar
                print("Şifre sıfırlama başarılı")
                showPasswordResetSuccess = true
            }
        }
    }
}



struct LoginSignUp_Previews: PreviewProvider {
    static var previews: some View {
        LoginSignUp()
    }
}

