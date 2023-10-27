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
      let tokenProtected = usersRoute.grouped(Token.authenticator())
      tokenProtected.get("me", use: getMyOwnUser)
      let passwordProtected =
        usersRoute.grouped(User.authenticator())
      passwordProtected.post("login", use: login)


  }

   func create(req: Request) throws -> EventLoopFuture<NewSession>
 { var token: Token!
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
    }.flatMap {
        // 1
        guard let newToken = try? user.createToken(source: .signup) else {
          return req.eventLoop.future(error: Abort(.internalServerError))
        }
        // 2
        token = newToken
        return token.save(on: req.db)
      }.flatMapThrowing {
        // 3
        NewSession(token: token.value, user: try user.asPublic())
      }

  }

  fileprivate func login(req: Request) throws -> EventLoopFuture<NewSession> {
      let user = try req.auth.require(User.self)
      // 2
      let token = try user.createToken(source: .login)

      return token
        .save(on: req.db)
        // 3
        .flatMapThrowing {
          NewSession(token: token.value, user: try user.asPublic())
      }
  }

  func getMyOwnUser(req: Request) throws -> User.Public {
     try req.auth.require(User.self).asPublic()

  }

  private func checkIfUserExists(_ username: String, req: Request) -> EventLoopFuture<Bool> {
    User.query(on: req.db)
      .filter(\.$username == username)
      .first()
      .map { $0 != nil }
  }
}
