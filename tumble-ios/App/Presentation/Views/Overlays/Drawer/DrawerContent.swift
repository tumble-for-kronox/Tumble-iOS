//
//  DrawerContent.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/16/22.
//

import SwiftUI

struct DrawerContent: View {
    @ObservedObject var viewModel: DrawerViewModel
    let showSheet: (DrawerRowType) -> Void
    var body: some View {
        ZStack {
            Color("SurfaceColor")
            VStack (alignment: .center, spacing: 0) {
                Group {
                    Menu {
                        Button(action: {
                            viewModel.onToggleTheme(value: false)
                        }, label: {
                            Text("Light")
                            Image(systemName: "sun.max")
                        })
                        Button(action: {
                            viewModel.onToggleTheme(value: true)
                        }, label: {
                            Text("Dark")
                            Image(systemName: "moon")
                        })
                        Button(action: {
                            viewModel.onDisableOverrideTheme()
                        }, label: {
                            Text("System")
                            Image(systemName: "apps.iphone")
                        })
                    } label: {
                        VStack {
                            Image(systemName: "paintbrush")
                                .font(.system(size: 17))
                                .frame(width: 17, height: 17)
                                .foregroundColor(Color("OnPrimary"))
                                .padding(15)
                                .background(Color("PrimaryColor").opacity(95))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            Text("Theme")
                                .padding(.top, 5)
                                .font(.subheadline)
                                .foregroundColor(Color("OnSurface"))
                        }
                    }
                    .padding(.bottom, 30)
                    
                    Menu {
                        Button(action: {
                            // stub
                        }, label: {
                            Text("System")
                        })
                        Button(action: {
                            // stub
                        }, label: {
                            Text("English")
                        })
                        Button(action: {
                            // stub
                        }, label: {
                            Text("German")
                        })
                        Button(action: {
                            // stub
                        }, label: {
                            Text("French")
                        })
                    } label: {
                        VStack {
                            Image(systemName: "globe.europe.africa")
                                .font(.system(size: 17))
                                .frame(width: 17, height: 17)
                                .foregroundColor(Color("OnPrimary"))
                                .padding(15)
                                .background(Color("PrimaryColor").opacity(95))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            Text("Language")
                                .padding(.top, 5)
                                .font(.subheadline)
                                .foregroundColor(Color("OnSurface"))
                        }
                    }
                    .padding(.bottom, 30)
                    
                    Menu {
                        Button(action: {
                            // stub
                        }, label: {
                            Text("15 minutes")
                        })
                        Button(action: {
                            // stub
                        }, label: {
                            Text("30 minutes")
                        })
                        Button(action: {
                            // stub
                        }, label: {
                            Text("1 hour")
                        })
                        Button(action: {
                            // stub
                        }, label: {
                            Text("3 hours")
                        })
                    } label: {
                        VStack {
                            Image(systemName: "bell.badge")
                                .font(.system(size: 17))
                                .frame(width: 17, height: 17)
                                .foregroundColor(Color("OnPrimary"))
                                .padding(15)
                                .background(Color("PrimaryColor").opacity(95))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            Text("Notifications")
                                .padding(.top, 5)
                                .font(.subheadline)
                                .foregroundColor(Color("OnSurface"))
                        }
                    }
                    .padding(.bottom, 30)
                }
                Group {
                    
                    DrawerItem(onClick: {
                        showSheet(.schedules)
                    }, title: "Schedules", image: "bookmark")
                    DrawerItem(onClick: {
                        showSheet(.school)
                    }, title: "School", image: "arrow.left.arrow.right")
                    
                    
                }
                Group {
                    DrawerItem(onClick: {
                        showSheet(.support)
                    }, title: "Support", image: "questionmark.circle")
                    
                }
                Spacer()
                Text("Tumble for Kronox V.3.0.0")
                    .padding(.bottom, 30)
                    .font(.caption)
                    .foregroundColor(Color("OnSurface"))
            }
            .padding(.top, 90)
            .padding(.leading, 15)
            .padding(.trailing, 15)
        }
    }
}
