require_relative 'classbench/analyser'
require_relative 'classbench/generator'
require_relative 'classbench/port_class'
require_relative 'classbench/rule'
require_relative 'classbench/trie'
require_relative 'classbench/trie_node'

require 'ip' # ruby-ip gem
require 'pp'

module Classbench
	VERSION = '0.1.2'

	def self.generate_prefix
		len = rand(33)

		(0...len).map { [0,1][rand(2)]}.join
	end

	def self.ip_to_binary_string(ip)
		ip = IP.new(ip)
		ip.to_b.to_s[0,ip.pfxlen]
	end

	def self.load_prefixes_from_file(filename)
		t = Trie.new

		prefixes = File.readlines(filename).map(&:chomp)
		prefixes.each do |pfx|
			t.insert ip_to_binary_string(pfx)
		end
		t
	end

	def self.analyse(filename)
		analyser = Analyser.new
		analyser.parse_openflow(File.read(filename))
		#pp analyser.rules
		analyser.calculate_stats
		#analyser.protocol_stats
		puts analyser.generate_seed
		#p analyser.protocol_port_class_stats
		#100.times { p analyser.generate_rule }
	end

	def self.generate(filename, count, db_generator_path)
		generator = Generator.new(filename, db_generator_path)
		has_openflow = generator.parse_seed

		#puts  YAML.dump(generator.openflow_section)
		rules = generator.generate_rules(count)
		if has_openflow
			rules.map!(&:to_vswitch_format)
		end

		puts rules
	end

end