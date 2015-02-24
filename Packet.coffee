
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
          when "uint16" then @addUInt16 field
          when "uint32" then @addUInt32 field
          when "int16" then @addInt16 field
          when "int32" then @addInt32 field
          when "float" then @addFloat field
          when "double" then @addDouble field
          when "string" then @addString field
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

  addUInt16: (field) ->
    @packetParseData.push {
      name: field
      read: (xml) ->
        return parseInt(xml[@name][0])
    }

    return @

  addUInt32: (field) ->
    @packetParseData.push {
      name: field
      read: (xml) ->
        return parseInt(xml[@name][0])
    }

    return @

  addInt16: (field) ->
    @packetParseData.push {
      name: field
      read: (xml) ->
        return parseInt(xml[@name][0])
    }

    return @

  addInt32: (field) ->
    @packetParseData.push {
      name: field
      read: (xml) ->
        return parseInt(xml[@name][0])
    }

    return @

  addDouble: (field) ->
    @packetParseData.push {
      name: field
      read: (xml) ->
        return parseFloat(xml[@name][0])
    }

    return @

  addFloat: (field) ->
    @packetParseData.push {
      name: field
      read: (xml) ->
        return parseFloat(xml[@name][0])
    }

    return @

  addString: (field) ->
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

  addUInt16Array: (field, count) ->
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

  addUInt32Array: (field, count) ->
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