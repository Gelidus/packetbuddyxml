Packet = require './Packet'
{parseString} = require 'xml2js'
xml = require 'xml2js'

module.exports = class Parser

  # @injectable
  constructor: (isServer, head, rootNode = 'root', conditionField = 'opcode') ->
    @isServer = isServer
    @head = if head? then head else new Packet("Head")
    @rootNode = rootNode
    @conditionField = conditionField

    @builder = new xml.Builder()

    @serverPackets = { }
    @clientPackets = { }
    @packetConditions = { }

  ###
    @return [Packet] packet representing head for all packets
  ###
  getHead: () =>
    return @head

  ###
    sets the current head to the given

    @param head [Packet] packet to be given as a head packet
    @return [Packet] new head packet instance
  ###
  setHead: (head) =>
    @head = head
    return @head

  ###
    Sets the condition field to the custom one

    @param conditionField[String] name of condition field in packet
  ###
  setConditionField:(@conditionField) ->

  registerPacket: (packet, isServerPacket, condition = null) ->

    if isServerPacket # switch between server and client packets
      @serverPackets[packet.name] = packet
    else
      @clientPackets[packet.name] = packet

    # register condition for current packet
    if (@isServer and not isServerPacket) or (not @isServer and isServerPacket)
      @registerCondition(packet.name, condition)
    else
      packet.addPredefinedValue(@conditionField, condition) # adds as predefined value

    return packet

  packet: (name, isServerPacket, structure) =>
    condition = @findCondition(structure) # get additional condition

    packet = new Packet(name, @head)
    packet.add(structure)

    return @registerPacket(packet, isServerPacket, condition)

  ###
  Finds condition field value in the packet structure

  @param structure [Array] an array of structured for the packet
  @return [String|Integer|Null] value of condition field or null if not found
  ###
  findCondition: (structure) ->
    for field in structure
      for name, value of field
        if name is @conditionField
          return value

    return null

  ###
  Returns packet from collection by given type

  @param packetName [String] packet name from collection
  @param isServer [Boolean] true if server packet is needed, else false. Default: true
  ###
  getPacket: (packetName, isServer = true) =>
    return if isServer then @serverPackets[packetName] else @clientPackets[packetName]

  registerCondition: (packetName, condition = null) ->
    if condition? and packetName?
      @packetConditions[condition] = packetName

  # parse given data by code tables
  parse: (data, callback, packetName = null) =>
    parsedData = { }

    parseString data.toString(), (err, result) =>
      parsed = result[@rootNode]

      if @getHead()?
        # type is now ignored due to xml
        for parser in @getHead().packetParseData
          parsedData[parser["name"]] = parser["read"](parsed)

      # retrieve condition from the parsed data ( should this be in head ? )
      condition = parsed[@conditionField][0]

      name = if packetName? then packetName else @packetConditions[condition]
      packet = @getPacket(name, !@isServer)

      if not packet?
        callback(null, null)
        return

      for parser in packet.packetParseData
        parsedData[parser["name"]] = parser["read"](parsed)

      callback(name, parsedData)

  serialize: (data, packetName, callback) =>
    packet = @getPacket(packetName, @isServer)

    for name, value of packet.predefinedValues
      data[name] = value if not data[name]? # assign default value if not defined

    obj = @builder.buildObject(data).replace(/(\r\n|\n|\r)/gm, '')

    callback(obj)