
module.exports = class Packet

  constructor: (@name, @head) ->
    @packetParseData = { } # array to store parse objects
    @predefinedValues = { }

  add: (structure) =>
    for field, type of structure
    	if @head? and @head.packetParseData[field]?
    		@predefinedValues[field] = type # now it's not type, but value
    	else
      	@packetParseData[field] = type

  length: () =>
    length = 0

    if @head?
      length += @head.length()

    length += Object.keys(@packetParseData).length

    return length