class Array

	def is_unidimensional?()

		for element in self

			if element.is_a?(Array)

				return false

			end

		end

		return true

	end

	def from_string( string )

		list_stack = [ self.clear() ]

		offset = 0

		runes = [ ":[", "]:", "[", "]" ]

		get = false

		while offset < string.size

			rune = string.which_rune_at( runes, offset )

			if get == true and rune != "]"

				list_stack.last.last << string[offset]

				offset += 1

				next

			elsif get == false and rune != nil

				offset += rune.size

			end

			if rune == "["

				list_stack.last.push( String.new() )

				get = true

			elsif rune == "]"

				get = false

			elsif rune == ":["

				list_stack << nil

				list_stack[-2] << Array.new()

				list_stack.last = list_stack[-2].last

			elsif rune == "]:"

				list_stack.pop()

			end

		end

		return list_stack.first

		return self

	end

	def to_string()

		string = String.new()

		list_stack = [ self ]

		position_stack = [ 0 ]

		while list_stack.size > 0

			if not ( position_stack.last < list_stack.last.size )

				string << "]:"

				list_stack.pop()

				position_stack.pop()

			else

				element = list_stack.last[position_stack.last]

				if element.is_a?(Array)

					string << ":["

					list_stack.push( element )

					position_stack.push( 0 )

				elsif element.is_a?(String)

					string << "["

					string << element

					string << "]"

				end

				position_stack.last += 1

			end

		end

		return string

	end

end

class String

	def is_number?()

		algarisms = [ "0", "1", "2", "3", "4", "5", "6", "7", "8", "9" ]

		position = 0

		while position < self.size

			character = self[position]

			if algarisms.include?( character ) == false

				return false

			end

			position += 1

		end

		return true

	end

	def which_rune_at( runes, reference )

		chosen = ""

		for rune in runes

			offset = 0

			match = true

			while offset < rune.size

				if self[reference+offset] != rune[offset]

					match = false

					break

				else

					offset += 1

				end

			end

			#puts match.inspect

			if match == true and rune.size > chosen.size

				chosen = rune

			end

		end

		if chosen == ""

			return  nil

		end

		return chosen

	end

end
