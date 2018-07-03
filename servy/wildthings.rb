module Wildthings
  require_relative 'bear'

  def self.list_bears
    [
      Bear::Bear.new(1, "Teddy", "Brown", true),
      Bear::Bear.new(2, "Smokey", "Black"),
      Bear::Bear.new(3, "Paddington", "Brown"),
      Bear::Bear.new(4, "Scarface", "Grizzly", true),
      Bear::Bear.new(5, "Snow", "Polar"),
      Bear::Bear.new(6, "Brutus", "Grizzly"),
      Bear::Bear.new(7, "Rosie", "Black", true),
      Bear::Bear.new(8, "Roscoe", "Panda"),
      Bear::Bear.new(9, "Iceman", "Polar", true),
      Bear::Bear.new(10, "Kenai", "Grizzly")
    ]
  end

  def self.get_bear(id)
    bear = []
    if id.is_a? Integer
      bear = list_bears.select{|bear| bear[:id] == id}
    elsif id.is_a? String
      bear = list_bears.select{|bear| bear[:id] == id.to_i}
    end
    bear[0]
  end
end