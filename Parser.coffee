Packet = require './Packet'
{parseString} = require 'xml2js'
xml = require 'xml2js'

module.exports = class Parser

  constructor: (@rootNode = 'root', @conditionField = 'opcode') ->
    @packetHead = null # packet header, may not be defined
    @builder = new xml.Builder()

    @packetCollection = { } # collection of packets

    # packet conditions are just for parser, not for serializer
    @packetConditions = { }

  registerHead: () ->
    @packetHead = new Packet("_Head");

    return @packetHead

  getHead: () ->
    return @packetHead

  setConditionField: (@conditionField) ->

  registerPacket: (name, condition = null) ->
    packet = new Packet(name, @packetHead)

    #if @getHead()?
    #  for parse in @getHead().packetParseData
    #    packet.packetParseData.push parse # give all packets header packet

    @packetCollection[name] = packet

    if name[0] not in ['S'] # @TODO: remove hack, represent C and S packets separately
      @registerCondition name, condition

    return packet # return newly created packet

  # registers condition for given packet name
  registerCondition: (packetName, condition) ->
    if condition?
      @packetConditions[condition] = packetName

  getPacket: (name) ->
    return @packetCollection[name] if @packetCollection[name]?
    return null

  # parse given data by packet name
  parseByName: (data, packetName, callback) =>
    @parse data, callback, packetName # just call parse with previously given name

  # parse given data by code tables
  parse: (data, callback, packetName = null) =>
    parsedData = { }

    parseString data.toString(), (err, result) =>
      parsed = result[@rootNode]

      if @getHead()?
        # type is now ignored due to xml
        for element, type of @getHead().packetParseData
          parsedData[element] = parsed[element][0]

      # retrieve condition from the parsed data ( should this be in head ? )
      condition = parsed[@conditionField][0]

      packetName = @packetConditions[condition] if not packetName?
      packet = @packetCollection[packetName]

      for element, type of packet.packetParseData
        parsedData[element] = parsed[element][0]

      callback(packetName, parsedData)

  serialize: (data, packetName, callback) =>
    packet = @packetCollection[packetName]

    for name, value of packet.predefinedValues
      data[name] = value if not data[name]? # assign default value if not defined

    obj = @builder.buildObject(data).replace(/(\r\n|\n|\r)/gm, '')

    callback(obj)