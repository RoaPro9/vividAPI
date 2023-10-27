//
//  File.swift
//  
//
//  Created by Roa Moha on 28/03/1445 AH.
//

import Vapor
import Fluent

enum SessionSource: Int, Content {
  case signup
  case login
}


final class Token: Model , Content {
    
    static let schema = "tokens"
    
    @ID(key: "id")
    var id: UUID?
    
    
    @Parent(key: "user_id")
    var user: User
    
    
    @Field(key: "value")
    var value: String
    
    
    @Field(key: "source")
    var source: SessionSource
    
    
    @Field(key: "expires_at")
    var expiresAt: Date?
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    init() {}
    init(id: UUID? = nil, userId: User.IDValue, token: String,
      source: SessionSource, expiresAt: Date?) {
      self.id = id
      self.$user.id = userId
      self.value = token
      self.source = source
      self.expiresAt = expiresAt
    }
}
extension Token: ModelTokenAuthenticatable {
  //1
  static let valueKey = \Token.$value
  static let userKey = \Token.$user

  //2
  var isValid: Bool {
    guard let expiryDate = expiresAt else {
      return true
    }
    
    return expiryDate > Date()
  }
}
