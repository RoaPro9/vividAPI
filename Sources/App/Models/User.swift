//
//  File.swift
//  
//
//  Created by Roa Moha on 30/03/1445 AH.
//

import Fluent
import Vapor

final class User: Model {
  struct Public: Content {
    let username: String
    let id: UUID
    let createdAt: Date?
    let updatedAt: Date?
  }
  
  static let schema = "users"
  
  @ID(key: "id")
  var id: UUID?
  
  @Field(key: "username")
  var username: String
  
  @Field(key: "password_hash")
  var passwordHash: String
  
  @Timestamp(key: "created_at", on: .create)
  var createdAt: Date?
  
  @Timestamp(key: "updated_at", on: .update)
  var updatedAt: Date?
  
  init() {}
  
  init(id: UUID? = nil, username: String, passwordHash: String) {
    self.id = id
    self.username = username
    self.passwordHash = passwordHash
  }
}

extension User {
  static func create(from userSignup: UserSignup) throws -> User {
    throw Abort(.notImplemented)
  }

  func asPublic() throws -> Public {
    Public(username: username,
           id: try requireID(),
           createdAt: createdAt,
           updatedAt: updatedAt)
  }
}
