class Brain

	attr_reader :neurons, :azimuth

	def initialize()

		@azimuth = Neuron.new()

		@neurons = [ @azimuth ]

	end

	def follow_name( neuron, name )

		connection = nil

		if name.is_a?( Integer )

			connection = neuron.connections[name]

		elsif name.is_number? == true

			connection = neuron.connections[name.to_i()]

		else

			for connection in neuron.connections

				if connection[ :"names" ].include?( name )

					return connection[ :"neuron" ]

				end
	
			end

		end

		if connection == nil

			return nil

		else

			return connection[ :"neuron" ]

		end

	end

	def follow_path( path )

		neuron = @azimuth

		if path.is_a?( String )

			array = Array.new()

			path = array.from_string( path )

		end

		for name in path

			neuron = follow_name( neuron, name )

		end

		return neuron

	end

	def insert_neuron( path_to_existent_neuron, idea, names: nil )

		neuron = self.follow_path( path_to_existent_neuron )

		if neuron == nil

			return nil

		end

		if names == nil

			names = Array.new()

		end

		new_neuron = Neuron.new()

		new_neuron.idea = idea

		connection = Hash[ :"neuron", new_neuron, :"names", names ]

		neuron.connections.push( connection )

		@neurons.push( new_neuron )

		position = neuron.connections.size - 1

		path = "[" + position.to_s() + "]"

		return path

	end

	def get_idea( path )

		neuron = follow_path( path )

		return neuron.idea

	end

	def assign_names( names, from_path, to_path )

		from_neuron = self.follow_path( from_path )

		puts to_path.inspect()

		to_neuron = self.follow_path( to_path )

		existent_connection = nil

		for connection in from_neuron.connections

			if connection[ :"neuron" ].object_id == to_neuron.object_id

				existent_connection = connection

				next

			end

			name_number = 0

			while name_number < connection[ :"names" ].size

				if names.include?( connection[ :"names" ][name_number] ) == true

					connection[ :"names" ].delete_at( name_number )

				else

					name_number += 1

				end

			end

		end

		if existent_connection == nil

			origin.connections << Hash[ :"neuron", to_neuron, :"names", names ]

		else

			existent_connection[ :"names" ] << names

		end

		return true

	end

	def connect( path_1, path_2 )

		neuron_1 = self.follow_path( path_1 )

		neuron_2 = self.follow_path( path_2 )

		connection = Hash[ :"neuron", neuron_2, :"names", nil ]

		neuron_1.connections.push( connection )

		return true

	end

end
