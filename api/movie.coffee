"use strict"
Hope    = require("zenserver").Hope
C       = require "../common/constants"
List    = require "../common/models/list"
Movie   = require "../common/models/movie"
omdb    = require "../common/lib/omdb"
Session = require "../common/session"
User    = require "../common/models/user"


module.exports = (server) ->

  server.get "/api/movie/search", (request, response) ->
    if request.required ["title"]
      Hope.shield([ ->
        Session request, response
      , (error, session) ->
        omdb.resource "GET", null, s: request.parameters.title
      ]).then (error, result) ->
        if error
          response.json message: error.message, error.code
        else
          response.json movies: result.Search


  server.get "/api/movie/info", (request, response) ->
    if request.required ["imdbid"]
      Hope.shield([ ->
        Session request, response
      , (error, session) ->
        omdb.resource "GET", null, i: request.parameters.imdbid
      , (error, movie) ->
        parameters = {}
        parameters[key.toLowerCase()] = value for key, value of movie
        Movie.searchOrRegister parameters
      ]).then (error, result) ->
        if error
          response.badRequest()
        else
          response.json movie: result.parse()


  server.post "/api/movie/fav", (request, response) ->
    if request.required ["imdbid"]
      Hope.shield([ ->
        Session request, response
      , (error, @session) =>
        Movie.search imdbid: request.parameters.imdbid, limit = 1
      , (error, movie) =>
        List.register user: @session, movie: movie._id, state: C.STATE.ACTIVE
      ]).then (error, result) ->
        if error
          response.json message: error.code, error.message
        else
          response.ok()


  server.delete "/api/movie/fav", (request, response) ->
    if request.required ["movie"]
      Hope.shield([ ->
        Session request, response
      , (error, session) ->
        List.delete user: session, movie: request.parameters.movie
      ]).then (error, result) ->
        if error
          response.json message: error.message, error.code
        else
          response.ok()
