//
//  SoulCatcher.swift
//  SoulCast
//
//  Created by Camvy Films on 2015-03-13.
//  Copyright (c) 2015 June. All rights reserved.
//

class SoulCatcher: NSObject {

  func soulFromUserInfo (userInfo:NSDictionary) -> Soul {
    let incomingSoul = Soul()
    //TODO: parse user info into Soul object
    return Soul()
  }
  
  func remoteUrlFromKey(NSString) -> NSString {
    
    return ""
  }

  /*
  Prefix Verb   URI Pattern                   Controller#Action
  souls GET    /souls(.:format)              souls#index
  POST   /souls(.:format)              souls#create
  new_soul GET    /souls/new(.:format)          souls#new
  edit_soul GET    /souls/:id/edit(.:format)     souls#edit
  soul GET    /souls/:id(.:format)          souls#show
  PATCH  /souls/:id(.:format)          souls#update
  PUT    /souls/:id(.:format)          souls#update
  DELETE /souls/:id(.:format)          souls#destroy
  api_souls GET    /api/souls(.:format)          api/souls#index
  POST   /api/souls(.:format)          api/souls#create
  new_api_soul GET    /api/souls/new(.:format)      api/souls#new
  edit_api_soul GET    /api/souls/:id/edit(.:format) api/souls#edit
  api_soul GET    /api/souls/:id(.:format)      api/souls#show
  PATCH  /api/souls/:id(.:format)      api/souls#update
  PUT    /api/souls/:id(.:format)      api/souls#update
  DELETE /api/souls/:id(.:format)      api/souls#destroy
  */
}
