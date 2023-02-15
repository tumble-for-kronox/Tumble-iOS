//
//  User.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-13.
//

import SwiftUI

struct UserOverview: View {
    
    @EnvironmentObject var user: User
    @ObservedObject var viewModel: AccountPage.AccountPageViewModel
    
    @Binding var userImage: UIImage?
    let name: String
    let username: String
    let schoolName: String
    
    @State private var inputImage: UIImage?
    @State private var showImagePicker: Bool = false
    
    let createToast: (ToastStyle, String, String) -> Void
    let toggleAutoSignup: (Bool) -> Void
    let userBookings: [Response.KronoxResourceData]
    let registeredExams: [Response.AvailableKronoxUserEvent]
    let updateUserImage: (UIImage) -> Void
    
    @Binding var autoSignup: Bool
    
    var body: some View {
        ZStack {
            Color.surface
            VStack {
                HStack {
                    Button(action: {
                        showImagePicker = true
                    }, label: {
                        UserAvatar(image: $userImage, name: name)
                    })
                    VStack (alignment: .leading, spacing: 0) {
                        Text(name)
                            .font(.system(size: 22, weight: .semibold, design: .rounded))
                        Text(username)
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                        Text(schoolName)
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .padding(.top, 5)
                        Spacer()
                    }
                    .padding(10)
                    .padding(.top, 20)
                }
                .padding()
                .padding(.top, 80)
                .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height / 3.5, alignment: .leading)
                .background(Color.background)
                .cornerRadius(15, corners: [.bottomLeft, .bottomRight])
            
                Spacer()
                ScrollView (.vertical) {
                    UserActions (title: "User options", image: "gearshape") {
                        Toggle(isOn: $autoSignup) {
                            Text("Automatic exam signup")
                                .sectionDividerEmpty()
                        }
                        .toggleStyle(SwitchToggleStyle(tint: .primary))
                        .onChange(of: autoSignup, perform: { (value: Bool) in
                            toggleAutoSignup(value)
                        })
                    }
                    UserActions (title: "Your bookings", image: "books.vertical",
                                 destination: AnyView(
                                    ResourceBookings()
                                        .environmentObject(user)
                                        .customNavigationBackButton(previousPage: "Account"))) {
                        if userBookings.isEmpty {
                            Text("No bookings yet")
                                .sectionDividerEmpty()
                        }
                    }
                    UserActions (title: "Your exams", image: "newspaper",
                                 destination: AnyView(
                                    EventBookings(viewModel: viewModel)
                                        .environmentObject(user)
                                        .customNavigationBackButton(previousPage: "Account"))) {
                        if let events = viewModel.completeUserEvent?.registeredEvents {
                            if !events.isEmpty {
                                ForEach(events) { event in
                                    /*@START_MENU_TOKEN@*/Text(event.eventId)/*@END_MENU_TOKEN@*/
                                }
                            } else {
                                Text("No registered exams yet")
                                    .sectionDividerEmpty()
                            }
                        }
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height / 1.85).cornerRadius(15)
                .background(Color.background)
                .cornerRadius(15, corners: [.topLeft, .topRight])
                
            }
            
        }
        .sheet(isPresented: $showImagePicker, onDismiss: loadImage, content: {
            ImagePicker(image: self.$inputImage)
        })
        .edgesIgnoringSafeArea([.top, .bottom])
        .onAppear {
            user.userEvents(completion: loadUserEvents)
        }
    }
    
    func loadUserEvents(result: Result<Response.KronoxCompleteUserEvent, Error>) -> Void {
        DispatchQueue.main.async {
            switch result {
            case .success(let events):
                viewModel.loadUserEvents(events: events, completion: {
                })
            case .failure(let failure):
                AppLogger.shared.info("\(failure.localizedDescription)")
            }
        }
    }
    
    func loadImage() -> Void {
        guard let inputImage = inputImage else { return }
        if inputImage.getSizeIn(.megabyte) <= 8 {
            updateUserImage(inputImage)
            createToast(.success, "New profile picture", "Successfully changed profile picture for your account")
        } else {
            createToast(.info, "Image too large", "Profile pictures are limited to 8MB")
        }
        
    }
    
}
