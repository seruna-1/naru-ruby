class Neuron

	attr_accessor :idea

	attr_reader :connections

	def initialize()

		@idea = String.new()

		@connections = Array.new()

	end

	def inspect()

		result = String.new()

		result << "This neuron has #{@connections.size} connections.\n"

		position = 0

		while position < @connections.size

			connection = @connections[position]

			neuron = connection[ :"neuron" ]

			result << "Connection at position [ #{ position } ] and names [ #{ connection[:'names'].inspect() } ] are associated to neuron with idea:\n"

			result << "#{ neuron.idea }\n\n"

			position += 1

		end

		return result

	end

end
