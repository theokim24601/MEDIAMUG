//
//  MugError.swift
//  MEDIAMUG
//
//  Created by hbkim on 2021/02/12.
//

enum MugError: Error {
  case invalidUrl
  case failedToLoad
  case failedToSave
  case failedToCreate
  case failedToDelete
}

enum RepositoryError: Error {
  case failedToLoad
  case failedToSave
  case failedToCreate
  case failedToDelete
}
