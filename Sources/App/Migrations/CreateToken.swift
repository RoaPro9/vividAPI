//
//  File.swift
//  
//
//  Created by Roa Moha on 28/03/1445 AH.
//

import Foundation
import Fluent


struct CreateTokens: Migration {
  func prepare(on database: Database) -> EventLoopFuture<Void> {
  
    database.schema(Token.schema)
          .id()
      .field("user_id", .uuid, .references("users", "id", onDelete: .cascade))
      .field("value", .string, .required)
      .unique(on: "value")
      .field("source", .int, .required)
      .field("created_at", .datetime, .required)
      .field("expires_at", .datetime)
   
      .create()
  }


  func revert(on database: Database) -> EventLoopFuture<Void> {
    database.schema(Token.schema).delete()
  }
}
