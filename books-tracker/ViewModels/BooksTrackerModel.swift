//
//  BooksTrackerModel.swift
//  books-tracker
//
//  Created by Pham on 4/25/23.
//

import Foundation
import SwiftUI
import CoreData
import UserNotifications

class BooksTrackerModel: ObservableObject {
      @Published var addNewBook: Bool = false
      @Published var title: String = ""
      @Published var bookColor: String = "Card-1"
      @Published var weekDays: [String] = []
      @Published var isRemainderOn: Bool = false
      @Published var remainderText: String = ""
      @Published var remainderDate: Date = Date()
      @Published var showTimePicker: Bool = false
      @Published var editBook: Book?
      @Published var notificationAccess: Bool = false
      
      init() {
            requestNotificationAccess()
      }
      
      func requestNotificationAccess() {
            UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .alert]) { status, _ in
                  DispatchQueue.main.async {
                        self.notificationAccess = status
                  }
            }
      }
      
      func addBook(context: NSManagedObjectContext) async -> Bool {
            var book: Book!
            
            if let editBook = editBook {
                  book = editBook
                  
                  if let notificationID = editBook.notificationID as? [String] {
                        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: notificationID)
                  }
            } else {
                  book = Book(context: context)
            }
            
            book.title = title
            book.color = bookColor
            book.weekDays = weekDays as NSObject
            book.isRemainderOn = isRemainderOn
            book.remainderText = remainderText
            book.notificationDate = remainderDate
            book.dateAdded = Date()
            book.notificationID = [] as [String] as NSObject
            
            if isRemainderOn {
                  if let ids = try? await scheduleNotification() {
                        book.notificationID = ids as [String] as NSObject
                        
                        if let _ = try? context.save() {
                              return true
                        }
                        
                        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
                  }
            } else {
                  if let _ = try? context.save() {
                        return true
                  }
            }
            
            return false
      }
      
      func scheduleNotification() async throws -> [String] {
            let content = UNMutableNotificationContent()
            content.title = "Books Remainder"
            content.subtitle = remainderText
            content.sound = UNNotificationSound.default
            
            var notificationID: [String] = []
            let calendar = Calendar.current
            let weekdaySymbols: [String] = calendar.weekdaySymbols
            
            for weekDay in weekDays {
                  let id = UUID().uuidString
                  let hour = calendar.component(.hour, from: remainderDate)
                  let min = calendar.component(.minute, from: remainderDate)
                  let day = weekdaySymbols.firstIndex { currentDay in
                        return currentDay == weekDay
                  } ?? -1
                  
                  if day != -1 {
                        var components = DateComponents()
                        components.hour = hour
                        components.minute = min
                        components.weekday = day + 1
                        
                        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
                        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
                        
                        notificationID.append(id)
                        
                        try await UNUserNotificationCenter.current().add(request)
                  }
            }
            
            return notificationID
      }
      
      func addHabbit(context: NSManagedObjectContext)async->Bool{
            var book: Book!
            
            if let editBook = editBook {
                  book = editBook
                 
                  if let notificationID = editBook.notificationID as? [String] {
                        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: notificationID)
                  }
            } else {
                  book = Book(context: context)
            }
            
            book.title = title
            book.color = bookColor
            book.weekDays = weekDays as NSObject
            book.isRemainderOn = isRemainderOn
            book.remainderText = remainderText
            book.notificationDate = remainderDate
            book.dateAdded = Date()
            book.notificationID = [] as [String] as NSObject
            
            if isRemainderOn {
                  if let ids = try? await scheduleNotification() {
                        book.notificationID = ids as [String] as NSObject
                        
                        if let _ = try? context.save() {
                              return true
                        }
                        
                        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
                  }
            } else {
                  if let _ = try? context.save(){
                        return true
                  }
            }
            
            return false
      }
      
      func deleteBook(context: NSManagedObjectContext) -> Bool {
            if let editBook = editBook {
                  if editBook.isRemainderOn{
                        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: editBook.notificationID as? [String] ?? [])
                  }
                  
                  context.delete(editBook)
                  
                  if let _ = try? context.save(){
                        return true
                  }
            }
            
            return false
      }
      
      func resetData() {
            title = ""
            bookColor = "Card-1"
            weekDays = []
            isRemainderOn = false
            remainderDate = Date()
            remainderText = ""
            editBook = nil
      }
      
      func restoreEditData() {
            if let editBook = editBook {
                  title = editBook.title ?? ""
                  bookColor = editBook.color ?? "Card-1"
                  weekDays = editBook.weekDays as? [String] ?? []
                  isRemainderOn = editBook.isRemainderOn
                  remainderDate = editBook.notificationDate ?? Date()
                  remainderText = editBook.remainderText ?? ""
            }
      }
      
      func doneStatus() -> Bool {
            let remainderStatus = isRemainderOn ? remainderText == "" : false
            
            if title == "" || weekDays.isEmpty || remainderStatus {
                  return false
            }
            
            return true
      }
}
