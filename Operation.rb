class OperationArray < Array

	def inspect()

		result = String.new()

		result << "\n"

		for operation in self

			result << "Operation #{operation.name.inspect()} with status #{operation.status.inspect()}, result #{operation.result.inspect()} and operands #{operation.operands.inspect()}.\n"

		end

		result << "End of operation stack.\n"

		return result

	end

end

class Operation

	attr_accessor :name, :operands, :status, :message, :result, :stack

	attr_reader :parser

	def initialize( parser )

		@operands = Array.new()

		@result = String.new()

		@status = :"not ready"

		@message = nil

		@parser = parser

		self.initialize_specific()

	end

	def operate()

		@message = String.new()

		if @parser.operations.last != self

			return self.emit_error( "Error on operation #{@name}. Last operation in stack of operations is not this operation ( objects are different ).\n" )

		elsif @status == :"done"

			return true

		end

		@message << "Starting operation #{@name} with stack #{@parser.operations.inspect()}.\n"

		done = self.operate_specific()

		@message << "Ending operation #{@name} with stack #{@parser.operations.inspect()}.\n"

		return done

	end

	def emit_error( message )

		@status = :"error"

		@message << message

		return false

	end

	def emit_success( result: nil )

		@status = :"done"

		@result = result

		return true

	end

end

class GetText < Operation

	attr_accessor :content_start_position, :content_end_position

	def initialize_specific()

		@name = :"get text"

	end

	def operate_specific()

		if  @operands.size == 2

			content_start_position = @operands.shift().to_i()

			content_end_position = @operands.shift().to_i()

			ignored_boundaries = [ " ", "\t" ]

			while ( ignored_boundaries.include?( @parser.recipe[content_start_position] ) == true ) and ( content_start_position <= content_end_position )

				content_start_position += 1

			end

			while ( ignored_boundaries.include?( @parser.recipe[content_end_position] ) == true ) and ( content_start_position <= content_end_position )

				content_end_position -= 1

			end

			return self.emit_success( result: @parser.recipe[content_start_position..content_end_position] )

		end

		return false

	end

end

class NeuronInsertion < Operation

	def initialize_specific()

		@name = :"insert neuron"

	end

	def operate_specific()

		if @operands.size > 1

			return self.emit_error( "Error operating [ insert neuron ]. There must be only one operand: the idea of the new neuron. However, there is more than one operand.\n" )

		elsif @operands.size == 1

			idea = @operands.pop()

			destination = nil

			if @parser.operations[-2].name == :"connect"

				destination = @parser.operations[-2].operands.pop()

				@parser.operations[-2].emit_success()

			else

				destination = @parser.path

			end

			return self.emit_success( result: @parser.brain.insert_neuron( destination, idea ) )

		end


	end

end

class ConnectNeurons < Operation

	def initialize_specific()

		@name = :"connect"

	end

	def operate_specific()

		if @operands.size > 2

			return self.emit_error( "Error on operation [ connect ]. There must be only 2 operands: a path to the neuron that will receive the connection and another path to the neuron that will be connected." )

		elsif @operands.size == 2

			@brain.connect( @operations.last[ :"operands" ][0], @operations.last[ :"operands" ][1] )

			return self.emit_success()

		end

	end

end

class NameAssignment < Operation

	attr_accessor :names_got

	def initialize_specific()

		@name = :"name assignment"

		@names_got = nil

	end

	def operate_specific()

		if ( @names_got != nil ) and ( @names_got < @operands.size )

			to_path = @operands.pop()

			@parser.brain.assign_names( @operands, @parser.path, to_path )

			return self.emit_success()

		end

	end

end

class OperationBlock < Operation

	attr_accessor :names_pushed_to_path

	def initialize_specific()

		@name = :"block"

		@names_pushed_to_path = nil

	end

	def operate_specific()

		if ( @names_pushed_to_path == nil ) and ( @operands.size == 1 )

			path_suffix = Array.new()

			path_suffix.from_string( @operands.pop() )

			@names_pushed_to_path = path_suffix.size

			@parser.path.concat( path_suffix )

		elsif @status == :"ready"
			
			@parser.path.pop( @names_pushed_to_path )

			return self.emit_success()

		end

	end

end

