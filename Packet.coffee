
module.exports = class Packet

  constructor: (@name, @head) ->
    @packetParseData = [] # array to store parse objects
    @predefinedValues = { }

  add: (structure) =>
    for node in structure
      for field, type of node
        # try to add predefined value, if field already exists, we should continue
        break if @addPredefinedValue(field, type)

        switch type
          when "uint8" then @addUInt8 field
          when "int8" then @addInt8 field
          when "uint16le" then @addUInt16LE field
          when "uint32le" then @addUInt32LE field
          when "int16le" then @addInt16LE field
          when "int32le" then @addInt32LE field
          when "floatle" then @addFloatLE field
          when "doublele" then @addDoubleLE field
          when "stringle" then @addStringLE field
          when /uint8 array [0-9]+:[0-9]+/ then @addUInt8Array field, field.split(' ')[2]
          when /uint16le array [0-9]+:[0-9]+/ then @addUInt16LEArray field, field.split(' ')[2]
          when /uint32le array [0-9]+:[0-9]+/ then @addUInt32LEArray field, field.split(' ')[2]
          else @addAny(field)

    return @

  isDefined: (name) =>
    if @head?
      for parser in @head.packetParseData
        return true if parser.name is name

    for parser in @packetParseData
      return true if parser.name is name

  addPredefinedValue: (field, value) =>
    if @isDefined(field)
      @predefinedValues[field] = value # already defined (wants default value assign)
      return true
    else
      return false

  length: () =>
    length = 0

    if @head?
      length += @head.length()

    length += Object.keys(@packetParseData).length

    return length

  addAny: (field) ->
    @packetParseData.push {
      name: field
      read: (xml) ->
        return xml[@name][0]
    }

    return @

  addUInt8: (field) ->
    @packetParseData.push {
      name: field
      read: (xml) ->
        return parseInt(xml[@name][0])
    }

    return @

  addInt8: (field) ->
    @packetParseData.push {
      name: field
      read: (xml) ->
        return parseInt(xml[@name][0])
    }

    return @

  addUInt16LE: (field) ->
    @packetParseData.push {
      name: field
      read: (xml) ->
        return parseInt(xml[@name][0])
    }

    return @

  addUInt32LE: (field) ->
    @packetParseData.push {
      name: field
      read: (xml) ->
        return parseInt(xml[@name][0])
    }

    return @

  addInt16LE: (field) ->
    @packetParseData.push {
      name: field
      read: (xml) ->
        return parseInt(xml[@name][0])
    }

    return @

  addInt32LE: (field) ->
    @packetParseData.push {
      name: field
      read: (xml) ->
        return parseInt(xml[@name][0])
    }

    return @

  addDoubleLE: (field) ->
    @packetParseData.push {
      name: field
      read: (xml) ->
        return parseFloat(xml[@name][0])
    }

    return @

  addFloatLE: (field) ->
    @packetParseData.push {
      name: field
      read: (xml) ->
        return parseFloat(xml[@name][0])
    }

    return @

  addStringLE: (field) ->
    @packetParseData.push {
      name: field
      read: (xml) ->
        return xml[@name][0]
    }

    return @

  addUInt8Array: (field, count) ->
    @packetParseData.push {
      name: field
      count: count
      read: (xml) ->
        arr = []
        for number in xml[@name]
          arr.push(parseInt(number))
        return arr
    }

    return @

  addUInt16LEArray: (field, count) ->
    @packetParseData.push {
      name: field
      count: count
      read: (xml) ->
        arr = []
        for number in xml[@name]
          arr.push(parseInt(number))
        return arr
    }

    return @

  addUInt32LEArray: (field, count) ->
    @packetParseData.push {
      name: field
      count: count
      read: (xml) ->
        arr = []
        for number in xml[@name]
          arr.push(parseInt(number))

        return arr
    }

    return @