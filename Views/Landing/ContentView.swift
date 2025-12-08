import SwiftUI

struct ContentView: View {
    @Binding var path: NavigationPath

    var body: some View {
        ZStack {
            Color.orange.ignoresSafeArea()

            VStack(spacing: 15) {
                Spacer()

                Image("fullLanding")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 140)

                Button(action: {
                    path.append(AppRoute.login)
                }) {
                    Text("Get Start")
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                        .frame(width: 160, height: 50)
                        .background(Color.purple)
                        .cornerRadius(30)
                }

                Spacer()
            }

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    ZStack {
                        Image("pasta")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 275)
                            .opacity(0.2)
                            .offset(x: 20, y: 20)
                        Image("pasta")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 170)
                            .padding(.leading, 180)
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(path: .constant(NavigationPath()))
    }
}
