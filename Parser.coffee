Packet = require './Packet'
{parseString} = require 'xml2js'
xml = require 'xml2js'

module.exports = class Parser

  constructor: (@rootNode = 'root', @conditionField = 'opcode') ->
    @packetHead = null # packet header
    @builder = new xml.Builder()

    @packetCollection = { } # collection of packets
    @packetNameConditions = { }

  registerHead: () ->
    @packetHead = new Packet("_Head");

    return @packetHead

  getHead: () ->
    return @packetHead

  setConditionField: (@conditionField) ->

  registerPacket: (name, condition = null) ->
    packet = new Packet(name)

    if @getHead()?
      for parse in @getHead().packetParseData
        packet.packetParseData.push parse # give all packets header packet

    @packetCollection[name] = packet
    @registerCondition name, condition

    return @packetCollection[name] # return packet

  # registers condition for given packet name
  registerCondition: (packetName, condition) ->
    if condition?
      @packetNameConditions[condition] = packetName

  getPacket: (name) ->
    return @packetCollection[name] if @packetCollection[name]?
    return null

  # parse given data by packet name
  parseByName: (data, packetName, callback) =>
    @autoParse data, callback, packetName

  # parse given data by code tables
  parse: (data, callback, packetName = null) =>
    parsedData = { }

    parseString data.toString(), (err, result) =>
      parsed = result[@rootNode]
      condition = parsed[@conditionField][0]

      packetName = @packetNameConditions[condition] if not packetName?
      packet = @packetCollection[packetName]

      for element, type of packet.packetParseData
        parsedData[element] = parsed[element][0]

      callback(packetName, parsedData)

  serialize: (data, packetName, callback) =>
    packet = @packetCollection[packetName]

    obj = @builder.buildObject(data).replace(/(\r\n|\n|\r)/gm, '')

    callback(obj)