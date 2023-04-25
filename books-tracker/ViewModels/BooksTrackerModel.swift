//
//  BooksTrackerModel.swift
//  books-tracker
//
//  Created by Pham on 4/25/23.
//

import Foundation
import SwiftUI
import UserNotifications

class BooksTrackerModel: ObservableObject {
      @Published var addNewBook: Bool = false
      @Published var title: String = ""
      @Published var bookColor: String = ""
}
