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
                                .caption().foregroundColor(Color("OnBackground"))
                            Image(systemName: "sun.max")
                        })
                        Button(action: {
                            viewModel.onToggleTheme(value: true)
                        }, label: {
                            Text("Dark")
                                .caption().foregroundColor(Color("OnBackground"))
                            Image(systemName: "moon")
                        })
                        Button(action: {
                            viewModel.onDisableOverrideTheme()
                        }, label: {
                            Text("System")
                                .caption().foregroundColor(Color("OnBackground"))
                            Image(systemName: "apps.iphone")
                        })
                    } label: {
                        VStack {
                            Image(systemName: "paintbrush")
                                .drawerIcon()
                            Text("Theme")
                                .caption()
                                .foregroundColor(Color("OnBackground"))
                        }
                    }
                    .padding(.bottom, 30)
                    
                    Menu {
                        Button(action: {
                            // stub
                        }, label: {
                            Text("System")
                                .caption().foregroundColor(Color("OnBackground"))
                        })
                        Button(action: {
                            // stub
                        }, label: {
                            Text("English")
                                .caption().foregroundColor(Color("OnBackground"))
                        })
                        Button(action: {
                            // stub
                        }, label: {
                            Text("German")
                                .caption().foregroundColor(Color("OnBackground"))
                        })
                        Button(action: {
                            // stub
                        }, label: {
                            Text("French")
                                .caption().foregroundColor(Color("OnBackground"))
                        })
                    } label: {
                        VStack {
                            Image(systemName: "globe.europe.africa")
                                .drawerIcon()
                            Text("Language")
                                .caption().foregroundColor(Color("OnBackground"))
                        }
                    }
                    .padding(.bottom, 30)
                    
                    Menu {
                        Button(action: {
                            // stub
                        }, label: {
                            Text("15 minutes")
                                .caption().foregroundColor(Color("OnBackground"))
                        })
                        Button(action: {
                            // stub
                        }, label: {
                            Text("30 minutes")
                                .caption().foregroundColor(Color("OnBackground"))
                        })
                        Button(action: {
                            // stub
                        }, label: {
                            Text("1 hour")
                                .caption().foregroundColor(Color("OnBackground"))
                        })
                        Button(action: {
                            // stub
                        }, label: {
                            Text("3 hours")
                                .caption().foregroundColor(Color("OnBackground"))
                        })
                    } label: {
                        VStack {
                            Image(systemName: "bell.badge")
                                .drawerIcon()
                            Text("Notifications")
                                .caption().foregroundColor(Color("OnBackground"))
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
