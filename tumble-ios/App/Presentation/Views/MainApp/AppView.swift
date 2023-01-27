//
//  HomeView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/20/22.
//

import SwiftUI

struct AppView: View {
    @ObservedObject var viewModel: AppViewModel
    
    @State private var isPickerSheetPresented = false
    @State private var pickerSheetView: AnyView? = nil
    @State private var isDrawerOpened: Bool = false
    @State private var eventSheetPositionSize: CGSize = CGSize(width: 0, height: UIScreen.main.bounds.height)
    @State private var blurRadius: CGFloat = 0
    
    private let drawerWidth: CGFloat = UIScreen.main.bounds.width/3
    
    init(viewModel: AppViewModel) {
        self.viewModel = viewModel
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithOpaqueBackground()
        coloredAppearance.backgroundColor = UIColor(Color("BackgroundColor"))
        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().compactAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
        UINavigationBar.appearance().tintColor = .white
    }

    
    var body: some View {
        ZStack(alignment: .leading) {
            Color("BackgroundColor")
            DrawerView(isDrawerOpened: isDrawerOpened, onClickDrawerRow: { draweRowType in
                viewModel.onClickDrawerRow(drawerRowType: draweRowType)
            }, drawerWidth: drawerWidth)
                
            NavigationView {
                ZStack {
                    Color("BackgroundColor")
                    VStack (alignment: .center) {
                        // Main home page view switcher
                        if viewModel.schoolIsChosen {
                            switch viewModel.selectedTab {
                            case .home:
                                HomePageView(viewModel: viewModel.homePageViewModel).onAppear {
                                    viewModel.onEndTransitionAnimation()
                                }
                            case .schedule:
                                ScheduleMainPageView(viewModel: viewModel.schedulePageViewModel, onTapCard: { event in
                                    self.animateEventSheetIntoView()
                                }).onAppear{
                                    viewModel.onEndTransitionAnimation()
                                }
                            case .account:
                                AccountPageView(viewModel: viewModel.accountPageViewModel).onAppear {
                                    viewModel.onEndTransitionAnimation()
                                }
                                
                            }
                        }
                        Spacer()
                        
                    }
                    
                    .padding([.leading, .trailing], 5)
                }
                
                .navigationTitle(
                    Text(viewModel.selectedTab.displayName))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading, content: {
                        DrawerButtonView(onToggleDrawer: onToggleDrawer, menuOpened: isDrawerOpened)
                    })
                    ToolbarItem(placement: .navigationBarTrailing, content: {
                        SearchButtonView(checkForNewSchedules: checkForNewSchedules)
                    })
                    ToolbarItemGroup(placement: .bottomBar, content: {
                        BottomBarView(onChangeTab: onChangeTab).environmentObject(viewModel)
                    })
                }
                .background(Color("BackgroundColor"))
                .font(.system(size: 22))
            }
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            .overlay(
                Group {
                    
                    if eventSheetToggled() {
                        
                        Color.clear
                            .onTapGesture {
                                print("Should be here")
                                self.animateEventSheetOutOfView()
                            }
                    }
                    
                    else if isDrawerOpened {
                        Color("BackgroundColor")
                            .opacity(isDrawerOpened ? 0.01 : 0)
                            .onTapGesture {
                                onToggleDrawer()
                            }
                    } else {
                        Color.clear
                        .opacity(0)
                        .onTapGesture {
                            print("Should not be here")
                            onToggleDrawer()
                        }
                    }
                }
            )
            .offset(x: isDrawerOpened ? drawerWidth : 0, y: 0)
            .animation(Animation.easeIn.speed(2.0), value: isDrawerOpened)
            .animation(Animation.easeOut.speed(2.0), value: !isDrawerOpened)
            .sheet(isPresented: $viewModel.showDrawerSheet, onDismiss: {
                viewModel.onToggleDrawerSheet()
            }, content: {
                DrawerSheetView(currentDrawerSheetView: viewModel.currentDrawerSheetView!, onSelectSchool: onSelectSchool, toggleDrawerSheet: onToggleDrawerSheet)
            })
            EventSheetView (eventSheetPositionSize: $eventSheetPositionSize, animateEventSheetOutOfView: animateEventSheetOutOfView) {
                Text("Some text!")
            }
        }
    }
    
    func onChangeTab(tab: TabType) -> Void {
        viewModel.onChangeTab(tab: tab)
    }
    
    func animateEventSheetIntoView() -> Void {
        self.eventSheetPositionSize.height = .zero
        withAnimation (.easeIn) { self.blurRadius = 3 }
    }
    
    func animateEventSheetOutOfView() -> Void {
        self.eventSheetPositionSize.height = UIScreen.main.bounds.height
        withAnimation (.easeOut) { self.blurRadius = 0 }
    }
    
    func onToggleDrawer() -> Void {
        isDrawerOpened.toggle()
    }
    
    func onToggleDrawerSheet() -> Void {
        viewModel.showDrawerSheet.toggle()
    }
    
    func onSelectSchool(school: School) -> Void {
        viewModel.onSelectSchool(school: school)
    }
    
    func eventSheetToggled() -> Bool {
        return self.eventSheetPositionSize.height < UIScreen.main.bounds.height
    }
    
    func checkForNewSchedules() -> Void {
        viewModel.schedulePageViewModel.loadSchedules()
    }
}

