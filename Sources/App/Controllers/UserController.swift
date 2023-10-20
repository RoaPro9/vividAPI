//
//  File.swift
//  
//
//  Created by Roa Moha on 28/03/1445 AH.
//

import Foundation
import Vapor
import Fluent

struct UserSignup: Content {
  let username: String
    var password: String
}

struct NewSession: Content {
  let token: String
  let user: User.Public
}

extension UserSignup: Validatable {
  static func validations(_ validations: inout Validations) {
    validations.add("username", as: String.self, is: !.empty)
    validations.add("password", as: String.self, is: .count(6...))
  }
}

struct UserController: RouteCollection {
  func boot(routes: RoutesBuilder) throws {
    let usersRoute = routes.grouped("users")
    usersRoute.post("signup", use: create)
  }

   func create(req: Request) throws -> EventLoopFuture<User.Public> {
    try UserSignup.validate(req)
       var userSignup = try req.content.decode(UserSignup.self)
    
      
       userSignup.password = try Bcrypt.hash(userSignup.password)
       
       let user =  User(username: userSignup.username, passwordHash: userSignup.password)
       
       print("1")
    return checkIfUserExists(userSignup.username, req: req).flatMap { exists in
      guard !exists else {
        return req.eventLoop.future(error: UserError.usernameTaken)
      }
        print("2")
      return user.save(on: req.db)
    }.flatMapThrowing {
      try user.asPublic()
    }
  }

  fileprivate func login(req: Request) throws -> EventLoopFuture<NewSession> {
    throw Abort(.notImplemented)
  }

  func getMyOwnUser(req: Request) throws -> User.Public {
    throw Abort(.notImplemented)
  }

  private func checkIfUserExists(_ username: String, req: Request) -> EventLoopFuture<Bool> {
    User.query(on: req.db)
      .filter(\.$username == username)
      .first()
      .map { $0 != nil }
  }
}
