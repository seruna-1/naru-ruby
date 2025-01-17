require_relative "extensions.rb"

require_relative "Operation.rb"

require_relative "Consumer.rb"

require_relative "Neuron.rb"

require_relative "Brain.rb"

require "rexml/document"

class Parser

	attr_accessor :recipe, :operations, :path

	attr_reader :brain

	def initialize( recipe )

		@recipe = recipe

	end

	def parse( verbosity: true )

		@brain = Brain.new()

		@path = Array.new()

		@operations = OperationArray.new()

		@operations << OperationBlock.new( self )

		@operations.last.names_pushed_to_path = 0

		@consumer = Consumer.new( self )

		while @consumer.consume() == true

			if ( verbosity == true ) then ( puts @consumer.message ) end

			while @operations.last.operate() == true

				if ( verbosity == true ) then ( puts @operations.last.message ) end

				if ( @operations.last.result != nil )

					@operations.at( -2 ).operands.append( @operations.last.result )

				end

				@operations.pop()

			end

			if ( @operations.last.status == :"error" ) then ( return nil ) end

		end

		if ( @consumer.status == :error ) then ( return nil ) else ( return @brain ) end

	end

end

class REXML::Formatters::Pretty

	def write_text( node, output )

		s = node.to_s()

		s.gsub!(/\s/,' ')

		s.squeeze!(" ")

		s = wrap(s, @width - @level)

		s = indent_text(s, @level, "\t", true)

		output << ("\t"*@level + s)

      end

      protected
      def write_element(node, output)
        output << "\t"*@level
        output << "<#{node.expanded_name}"

        node.attributes.each_attribute do |attr|
          output << " "
          attr.write( output )
        end unless node.attributes.empty?

        if node.children.empty?
          if @ie_hack
            output << " "
          end
          output << "/"
        else
          output << ">"
          # If compact and all children are text, and if the formatted output
          # is less than the specified width, then try to print everything on
          # one line
          skip = false
          if compact
            if node.children.inject(true) {|s,c| s & c.kind_of?(Text)}
              string = +""
              old_level = @level
              @level = 0
              node.children.each { |child| write( child, string ) }
              @level = old_level
              if string.length < @width
                output << string
                skip = true
              end
            end
          end
          unless skip
            output << "\n" * 2
            @level += @indentation
            node.children.each { |child|
#              next if child.kind_of?(Text) and child.to_s.strip.length == 0
              write( child, output )
              output << "\n" * 2
            }
            @level -= @indentation
            output << "\t"*@level
          end
          output << "</#{node.expanded_name}"
        end
        output << ">"
      end

      def write_cdata( node, output)
        output << "\t" * @level
        super
      end

end

class NaruToHtml

	attr_accessor :html

	def initialize( brain )

		@brain = brain

		@html_out = nil

		@html_dom = nil

	end

	def convert()

		neurons = [ @brain.azimuth ]

		names = [ 0 ]

		@html_dom = REXML::Document.new( "<html></html>" )

		html_elements = [ @html_dom.root ]

		while ( names.size > 0 )

			neuron = @brain.follow_name( neurons.last, names.last )

			names[-1] += 1

			if ( neuron == nil )

				neurons.pop()

				names.pop()

				html_elements.pop()

				next

			end

			if ( neuron.idea == "Paragraph" )

				element = html_elements.last.add_element( "p" )

				neurons << neuron

				names << 0

				html_elements << element

			elsif ( neurons[-1].idea == "Paragraph" )

				puts "Neuron idea #{neuron.idea}"

				puts html_elements.inspect()

				puts neuron.inspect()

				puts names.inspect()

				element = html_elements.last.add_element( "span" )

				element.add_text( neuron.idea )

			end

		end

		@html_dom.write({indent: 1})

	end

end
