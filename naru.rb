require_relative "extensions.rb"

require_relative "Operation.rb"

require_relative "Neuron.rb"

require_relative "Brain.rb"

class Parser

	attr_accessor :recipe, :operations, :path

	attr_reader :brain

	def initialize( recipe )

		@recipe = recipe

	end

	def parse()

		@brain = Brain.new()

		@path = Array.new()

		@operations = OperationArray.new()

		@operations << OperationBlock.new( self )

		@operations.last.names_pushed_to_path = 0

		@consumer = Consumer.new( self )

		while @consumer.consume() == true

			puts @consumer.message + "-----------"

			while @operations.last.operate() == true

				puts "hello"

				puts @operations.last.message

				if @operations.last.result != nil

					@operations[-2].operands << @operations.last.result

				end

				@operations.pop()

				puts "Pushed #{@operations[-1].operands}"

			end

			if @operations.last.status == :"error"

				return nil

			end

		end

		if @consumer.status == :error

			return nil

		end

		return @brain

	end

end

class Consumer

	attr_accessor :position

	attr_reader :status, :message

	def initialize( parser )

		@parser = parser

		@status = nil

		@message = nil

		@runes = [ :"\n", :"+", :"[", :"]", :"~", :":[", :"]:", :"at", :"-->", :"#" ]

		@position = Hash[ :"absolute", 0, :"line", 0, :"column", 0 ]

		@rune = nil

	end

	def emit_error( message )

		@status = :"error"

		@message << "Error on #{@position}.\n" + message

		return false

	end

	def consume()

		@rune = nil

		@message = String.new()

		@message << "Consuption started at #{@position.inspect()}.\n With operations #{@parser.operations.inspect()}\n"

		while @position[ :"absolute" ] < @parser.recipe.size

			@rune = @parser.recipe.which_rune_at( @runes, @position[ :"absolute" ] )

			if @rune == nil

				@position[ :"absolute" ] += 1

				@position[ :"column" ] += 1

				next

			else

				@position[ :"absolute" ] += @rune.size

				@position[ :"column" ] += @rune.size

				@message << "Then obtained rune #{@rune.inspect()} and got to position #{@position.inspect()}.\n"

				break

			end

		end

		if @position[ :"absolute" ] >= @parser.recipe.size

			return false

		end

		case @rune

		when :"\n"

			if @parser.operations.last.name == :"get text"

#				@parser.operations.last = GetLines.new( @parser )

			else

				@position[ :"column" ] = 0

				@position[ :"line" ] += 1

			end

		when :"+"

			@parser.operations << NeuronInsertion.new( @parser )

		when :"-->"

			if @parser.operations.last.name != :"name assignment"

				return self.emit_error( "Found operator [ --> ] on operation [ #{ @parser.operations.last.name } ], but it should be on a operation [name assignment], in order to mark the end of name addition, so the operation would only wait to a neuron path in order to be operated.\n" )

			else

				@parser.operations.last.names_got = @parser.operations.last.operands.size

			end

		when :"~"

			if @parser.operations.last.name != :"block"

				return self.emit_error( "Found operator [ ~ ], namely [ connect ]. It should use the operands of a block operation as names to get a neuron, push it to @neuron_stack and clear operands, but last operation is not a block.\n" )

			else

				@parser.operations << ConnectNeurons.new( @parser )

				puts "From #{@parser.operations.inspect()}"

				path = @parser.operations[-2].operands.pop()

				@parser.operations.last.operands << path

				puts "Got #{path}"

			end

		when :"["

			if @parser.operations.last.name != :"get text"

				@parser.operations << GetText.new( @parser )

				start_of_content = @position[ :"absolute" ].to_s()

				@parser.operations.last.operands << start_of_content

			end

		when :"]"

			if @parser.operations.last.name == :"get text"

				end_of_content = @position[ :"absolute" ] - @rune.size - 1

				end_of_content = end_of_content.to_s()

				@parser.operations.last.operands << end_of_content

			end

		when :":["

			if @parser.operations.last.name != :"block"

				return self.emit_error( "Found opener [ :[ ], it should take the last operand of a block, transform the path in string form to array form, concatenate this array to @path and create a new operation [ block ], but last operation is not a block.\n" )

			else

				@parser.operations << OperationBlock.new( @parser )

				@parser.operations.last.operands << @parser.operations[-2].operands.pop()

			end

		when :"]:"

			if @parser.operations.last.name != :"block"

				return self.emit_error( "Found closer [ \]: ], it should close a block, but last operation is not a block.\n" )

			else

				@parser.operations.last.status = :"ready"

			end

		when :"#"

			if @parser.operations.last.name != :"block"

				return self.emit_error( "Name assignment must run on block.\n" )

			elsif @parser.operations.last.name != :"name assignment" 

				@parser.operations << NameAssignment.new( @parser )

			end

		end

		@message << "Consuption ended with operations #{@parser.operations.inspect()}\n"

		return true

	end

end
