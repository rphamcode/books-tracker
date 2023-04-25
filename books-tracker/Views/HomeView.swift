//
//  HomeView.swift
//  books-tracker
//
//  Created by Pham on 4/25/23.
//

import SwiftUI

struct HomeView: View {
      @FetchRequest(entity: Book.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Book.dateAdded, ascending: false)], predicate: nil, animation: .easeInOut) var books: FetchedResults<Book>
      @StateObject var booksTrackerModel: BooksTrackerModel = .init()
      
      var body: some View {
            VStack(spacing: 0) {
                  Text("Books")
                        .font(.title2.bold())
                        .frame(maxWidth: .infinity)
                        .overlay(alignment: .trailing) {
                              Button {
                                    
                              } label: {
                                    Image(systemName: "gearshape")
                                          .font(.title3)
                                          .foregroundColor(.primary)
                              }
                        }
                        .padding(.bottom,10)
                  
                  ScrollView(books.isEmpty ? .init() : .vertical, showsIndicators: false) {
                        VStack(spacing: 15){
                              ForEach(books) { book in
                                    BookCardView(book: book)
                              }
                              
                              Button {
                                    booksTrackerModel.addNewBook.toggle()
                              } label: {
                                    Label {
                                          Text("New book")
                                    } icon: {
                                          Image(systemName: "plus.circle")
                                    }
                                    .font(.callout.bold())
                                    .foregroundColor(.primary)
                              }
                              .padding(.top,15)
                              .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        }
                        .padding(.vertical)
                  }
            }
            .frame(maxHeight: .infinity,alignment: .top)
            .padding()
            .sheet(isPresented: $booksTrackerModel.addNewBook) {
                  booksTrackerModel.resetData()
            } content: {
                  AddNewBookView()
                        .environmentObject(booksTrackerModel)
            }
      }
      
      @ViewBuilder
      func BookCardView(book: Book) -> some View {
            VStack(spacing: 6) {
                  HStack {
                        Text(book.title ?? "")
                              .font(.callout)
                              .fontWeight(.semibold)
                              .lineLimit(1)
                        
                        Image(systemName: "bell.badge.fill")
                              .font(.callout)
                              .foregroundColor(Color(book.color ?? "Card-1"))
                              .scaleEffect(0.9)
                              .opacity(book.isRemainderOn ? 1 : 0)
                        
                        Spacer()
                        
                        let count = (book.weekDays as? [String])?.count ?? 0
                        
                        Text(count == 7 ? "Everyday" : "\(count) times a week")
                              .font(.caption)
                              .foregroundColor(.gray)
                  }
                  .padding(.horizontal,10)
                  
                  let calendar = Calendar.current
                  let currentWeek = calendar.dateInterval(of: .weekOfMonth, for: Date())
                  let symbols = calendar.weekdaySymbols
                  let startDate = currentWeek?.start ?? Date()
                  let activeWeekDays = book.weekDays as? [String] ?? []
                  let activePlot = symbols.indices.compactMap { index -> (String,Date) in
                        let currentDate = calendar.date(byAdding: .day, value: index, to: startDate)
                        
                        return (symbols[index],currentDate!)
                  }
                  
                  HStack(spacing: 0) {
                        ForEach(activePlot.indices,id: \.self) { index in
                              let item = activePlot[index]
                              
                              VStack(spacing: 6) {
                                    Text(item.0.prefix(3))
                                          .font(.caption)
                                          .foregroundColor(.gray)
                                    
                                    let status = activeWeekDays.contains { day in
                                          return day == item.0
                                    }
                                    
                                    Text(getDate(date: item.1))
                                          .font(.system(size: 14))
                                          .fontWeight(.semibold)
                                          .padding(8)
                                          .foregroundColor(status ? .white : .primary)
                                          .background {
                                                Circle()
                                                      .fill(Color(book.color ?? "Card-1"))
                                                      .opacity(status ? 1 : 0)
                                          }
                              }
                              .frame(maxWidth: .infinity)
                        }
                  }
                  .padding(.top,15)
            }
            .padding(.vertical)
            .padding(.horizontal,6)
            .background {
                  RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color("TFBG").opacity(0.5))
            }
            .onTapGesture {
                  booksTrackerModel.editBook = book
                  booksTrackerModel.restoreEditData()
                  booksTrackerModel.addNewBook.toggle()
            }
      }
      
      func getDate(date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd"
            
            return formatter.string(from: date)
      }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
