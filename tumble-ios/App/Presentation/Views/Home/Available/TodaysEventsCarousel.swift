//
//  TodaysEventsCarousel.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-04-03.
//

import SwiftUI

struct TodaysEventsCarousel: View {
    
    let courseColors: CourseAndColorDict
    @Binding var eventsForToday: [WeekEventCardModel]
    @Binding var swipedCards: Int
    
    var body: some View {
        ZStack {
            if eventsForToday.isEmpty {
                Text(NSLocalizedString("No events for today", comment: ""))
                    .font(.system(size: 16))
                    .foregroundColor(.onBackground)
            } else {
                ForEach(eventsForToday.indices.reversed(), id: \.self) { index in
                    let event = eventsForToday[index].event
                    let color = courseColors[event.course.id]?.toColor() ?? .white
                    HStack {
                        VerboseEventButtonLabel(event: event, color: color)
                            .frame(
                                width: getCardWidth(index: index),
                                height: getCardHeight(index: index)
                            )
                            .background(event.isSpecial ? Color.red.opacity(0.2) : Color.surface)
                            .cornerRadius(20)
                            .offset(x: getCardOffset(index: index))
                            .rotationEffect(.init(degrees: getCardRotation(index: index)))
                            .if(index != eventsForToday.count - 1, transform: { view in
                                view.shadow(
                                    color: Color.black.opacity(0.1),
                                    radius: (index - swipedCards) <= 2 ? 2 : 0, x: 5, y: 2
                                )
                            })
                        Spacer()
                    }
                    .frame(height: 160)
                    .contentShape(Rectangle())
                    .offset(x: eventsForToday[index].offset)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged({ value in
                                onChanged(value: value, index: index)
                            })
                            .onEnded({ value in
                                onEnded(value: value, index: index)
                            })
                    )
                }
            }
        }
        HStack {
            Spacer()
            Button(action: resetCards, label: {
                Image(systemName: "arrow.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.onPrimary)
                    .padding(10)
                    .background(Color.primary)
                    .clipShape(Circle())
                
            })
            .buttonStyle(AnimatedButtonStyle())
        }
        .padding(.top, 10)
    }
        
    func resetCards() {
        for index in eventsForToday.indices {
            withAnimation(.spring()) {
                eventsForToday[index].offset = 0
                swipedCards = 0
            }
        }
    }
    
    func getCardRotation(index: Int) -> Double {
        let boxWidth = Double(getRect().width / 3)
        let offset = Double(eventsForToday[index].offset)
        let angle: Double = 8
        return (offset / boxWidth) * angle
    }
    
    func onChanged(value: DragGesture.Value, index: Int) {
        if value.translation.width < 0 && eventsForToday.count > 1 {
            eventsForToday[index].offset = value.translation.width
        }
    }
    
    func onEnded(value: DragGesture.Value, index: Int) {
        withAnimation {
            if -value.translation.width > getRect().width / 3 {
                eventsForToday[index].offset = -getRect().width
                swipedCards += 1
            } else {
                eventsForToday[index].offset = 0
            }
        }
        if swipedCards == eventsForToday.count {
            resetCards()
        }
    }
    
    func getCardHeight(index: Int) -> CGFloat {
        let height: CGFloat = 160
        let cardHeight = (index - swipedCards) <= 3 ? CGFloat(index - swipedCards) * 35 : 30
        return height - cardHeight
    }
    
    func getCardWidth(index: Int) -> CGFloat {
        let boxWidth = getRect().width - 60
        return boxWidth
    }
    
    func getCardOffset(index: Int) -> CGFloat {
        return (index - swipedCards) <= 3 ? CGFloat(index - swipedCards) * 10 : 0
    }
    
}
