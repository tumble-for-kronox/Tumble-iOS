//
//  TodaysEventsCarousel.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-04-03.
//

import SwiftUI

struct TodaysEventsCarousel: View {
    @Binding var swipedCards: Int
    @Binding var weekEventCards: [WeekEventCardModel]
    
    var body: some View {
        ZStack {
            if weekEventCards.isEmpty {
                Text(NSLocalizedString("No events for today", comment: ""))
                    .font(.system(size: 16))
                    .foregroundColor(.onBackground)
            } else {
                ForEach(weekEventCards.indices.reversed(), id: \.self) { index in
                    let event = weekEventCards[index].event
                    CarouselCard(
                        event: event,
                        index: index,
                        eventsForToday: weekEventCards,
                        swipedCards: $swipedCards
                    )
                    .frame(height: 160)
                    .contentShape(Rectangle())
                    .offset(x: weekEventCards[index].offset)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                onChanged(value: value, index: index)
                            }
                            .onEnded { value in
                                onEnded(value: value, index: index)
                            }
                    )
                }
            }
        }
        resetButton
    }
        
    var resetButton: some View {
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
        for index in weekEventCards.indices {
            withAnimation(.spring()) {
                weekEventCards[index].offset = 0
                swipedCards = 0
            }
        }
    }
    
    func onChanged(value: DragGesture.Value, index: Int) {
        if value.translation.width < 0 && weekEventCards.count > 1 {
            weekEventCards[index].offset = value.translation.width
        }
    }
    
    func onEnded(value: DragGesture.Value, index: Int) {
        withAnimation {
            if -value.translation.width > getRect().width / 3 {
                weekEventCards[index].offset = -getRect().width
                swipedCards += 1
            } else {
                weekEventCards[index].offset = 0
            }
        }
        if swipedCards == weekEventCards.count {
            resetCards()
        }
    }
}

private struct CarouselCard: View {
    let event: Event
    let index: Int
    let eventsForToday: [WeekEventCardModel]
    @Binding var swipedCards: Int
    
    var body: some View {
        HStack {
            VerboseEventButtonLabel(event: event)
                .frame(
                    width: getCardWidth(index: index),
                    height: getCardHeight(index: index)
                )
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
    }
    
    func getCardRotation(index: Int) -> Double {
        let boxWidth = Double(getRect().width / 3)
        let offset = Double(eventsForToday[index].offset)
        let angle: Double = 8
        return (offset / boxWidth) * angle
    }
    
    func getCardHeight(index: Int) -> CGFloat {
        let height: CGFloat = 160
        let cardHeight = (index - swipedCards) <= 3 ? CGFloat(index - swipedCards) * 35 : 30
        return height - cardHeight
    }
    
    func getCardWidth(index: Int) -> CGFloat {
        let boxWidth = getRect().width - 35
        return boxWidth
    }
    
    func getCardOffset(index: Int) -> CGFloat {
        return (index - swipedCards) <= 3 ? CGFloat(index - swipedCards) * 10 : 0
    }
}
