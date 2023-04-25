//
//  AddNewBookView.swift
//  books-tracker
//
//  Created by Pham on 4/25/23.
//

import SwiftUI

struct AddNewBookView: View {
      @EnvironmentObject var booksTrackerModel: BooksTrackerModel
      @Environment(\.self) var env
      
      var body: some View {
            NavigationView {
                  VStack(spacing: 15) {
                        TextField("Title", text: $booksTrackerModel.title)
                              .padding(.horizontal)
                              .padding(.vertical,10)
                              .background(Color("TFBG").opacity(0.4),in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                        
                        HStack(spacing: 0) {
                              ForEach(1...7,id: \.self) { index in
                                    let color = "Card-\(index)"
                                    
                                    Circle()
                                          .fill(Color(color))
                                          .frame(width: 30, height: 30)
                                          .overlay(content: {
                                                if color == booksTrackerModel.bookColor {
                                                      Image(systemName: "checkmark")
                                                            .font(.caption.bold())
                                                            .foregroundColor(.white)
                                                }
                                          })
                                          .onTapGesture {
                                                withAnimation {
                                                      booksTrackerModel.bookColor = color
                                                }
                                          }
                                          .frame(maxWidth: .infinity)
                              }
                        }
                        .padding(.vertical)
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 6) {
                              Text("Frequency")
                                    .font(.callout.bold())
                              
                              let weekDays = Calendar.current.weekdaySymbols
                              
                              HStack(spacing: 10) {
                                    ForEach(weekDays,id: \.self) { day in
                                          let index = booksTrackerModel.weekDays.firstIndex { value in
                                                return value == day
                                          } ?? -1
                                           
                                          Text(day.prefix(2))
                                                .fontWeight(.semibold)
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical,12)
                                                .foregroundColor(index != -1 ? .white : .primary)
                                                .background{
                                                      RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                            .fill(index != -1 ? Color(booksTrackerModel.bookColor) : Color("TFBG").opacity(0.4))
                                                }
                                                .onTapGesture {
                                                      withAnimation {
                                                            if index != -1 {
                                                                  booksTrackerModel.weekDays.remove(at: index)
                                                            } else {
                                                                  booksTrackerModel.weekDays.append(day)
                                                            }
                                                      }
                                                }
                                    }
                              }
                              .padding(.top,15)
                        }
                        
                        Divider()
                              .padding(.vertical,10)
                        
                        HStack {
                              VStack(alignment: .leading, spacing: 6) {
                                    Text("Remainder")
                                          .fontWeight(.semibold)
                                    
                                    Text("Just notification")
                                          .font(.caption)
                                          .foregroundColor(.gray)
                              }
                              .frame(maxWidth: .infinity,alignment: .leading)
                              
                              Toggle(isOn: $booksTrackerModel.isRemainderOn) {}
                                    .labelsHidden()
                        }
                        .opacity(booksTrackerModel.notificationAccess ? 1 : 0)
                        
                        HStack(spacing: 12) {
                              Label {
                                    Text(booksTrackerModel.remainderDate.formatted(date: .omitted, time: .shortened))
                              } icon: {
                                    Image(systemName: "clock")
                              }
                              .padding(.horizontal)
                              .padding(.vertical,12)
                              .background(Color("TFBG").opacity(0.4),in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                              .onTapGesture {
                                    withAnimation {
                                          booksTrackerModel.showTimePicker.toggle()
                                    }
                              }
                              
                              TextField("Remainder Text", text: $booksTrackerModel.remainderText)
                                    .padding(.horizontal)
                                    .padding(.vertical,10)
                                    .background(Color("TFBG").opacity(0.4),in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                        }
                        .frame(height: booksTrackerModel.isRemainderOn ? nil : 0)
                        .opacity(booksTrackerModel.isRemainderOn ? 1 : 0)
                        .opacity(booksTrackerModel.notificationAccess ? 1 : 0)
                  }
                  .animation(.easeInOut, value: booksTrackerModel.isRemainderOn)
                  .frame(maxHeight: .infinity,alignment: .top)
                  .padding()
                  .navigationBarTitleDisplayMode(.inline)
                  .navigationTitle(booksTrackerModel.editBook != nil ? "Edit Book" : "Add Book")
                  .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                              Button {
                                    env.dismiss()
                              } label: {
                                    Image(systemName: "xmark.circle")
                              }
                              .tint(.primary)
                        }
                        
                        ToolbarItem(placement: .navigationBarLeading) {
                              Button {
                                    if booksTrackerModel.deleteBook(context: env.managedObjectContext) {
                                          env.dismiss()
                                    }
                              } label: {
                                    Image(systemName: "trash")
                              }
                              .tint(.red)
                              .opacity(booksTrackerModel.editBook == nil ? 0 : 1)
                        }
                        
                        ToolbarItem(placement: .navigationBarTrailing) {
                              Button("Done"){
                                    Task{
                                          if await booksTrackerModel.addBook(context: env.managedObjectContext) {
                                                env.dismiss()
                                          }
                                    }
                              }
                              .tint(.primary)
                              .disabled(!booksTrackerModel.doneStatus())
                              .opacity(booksTrackerModel.doneStatus() ? 1 : 0.6)
                        }
                  }
            }
            .overlay {
                  if booksTrackerModel.showTimePicker {
                        ZStack{
                              Rectangle()
                                    .fill(.ultraThinMaterial)
                                    .ignoresSafeArea()
                                    .onTapGesture {
                                          withAnimation {
                                                booksTrackerModel.showTimePicker.toggle()
                                          }
                                    }
                              
                              DatePicker.init("", selection: $booksTrackerModel.remainderDate,displayedComponents: [.hourAndMinute])
                                    .datePickerStyle(.wheel)
                                    .labelsHidden()
                                    .padding()
                                    .background {
                                          RoundedRectangle(cornerRadius: 10)
                                                .fill(Color("TFBG"))
                                    }
                                    .padding()
                        }
                  }
            }
      }
}

struct AddNewBookView_Previews: PreviewProvider {
    static var previews: some View {
        AddNewBookView()
                .environmentObject(BooksTrackerModel())
                .preferredColorScheme(.dark)
    }
}
