require_relative "../naru.rb"

parser = Parser.new( File.read( "test-to-html.naru" ) )

brain = parser.parse( verbosity: false )

if brain != nil

	puts "Brain has  #{ brain.neurons.size.inspect() } neurons in it."

	puts "Inspecting azimuth."

	puts brain.azimuth.inspect()

	puts "Inspecting last neuron on azimut."

	puts brain.azimuth.connections[-1][:"neuron"].inspect()

else

	puts "Brain is nil.\n"

end

naru2html = NaruToHtml.new( brain )

naru2html.convert()
