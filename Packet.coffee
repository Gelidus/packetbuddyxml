
module.exports = class Packet

  constructor: (@name) ->
    @packetParseData = { }# array to store parse objects

  add: (structure) ->
    for field, type of structure
      @packetParseData[field] = type