require "configparser/version"

# DESCRIPTION: parses configuration files compatible with Python's ConfigParser

class ConfigParser < Hash
	def initialize(fname = nil)
    self.parse(File.open(fname, "r").each_line) if fname
  end
  
  def parse(input_source)
		section = nil
		key = nil
		input_source.each do |line|
			next if (line =~ /^(#|;)/)
			
			# parse out the lines of the config
			if line =~ /^(.+?)\s*[=:]\s*(.+)$/ # handle key=value lines
				if section
					self[section] = {} unless self[section]
					key = $1
					self[section][key] = $2
				else
					key = $1
					self[key] = $2
				end
			elsif line =~ /^\[(.+?)\]/ # handle new sections
				section = $1
			elsif line =~ /^\s+(.+?)$/ # handle continued lines
				if section
					self[section][key] += " #{$1}";
				else
					self[key] += " #{$1}"
				end
			elsif line =~ /^([\w\d\_\-]+)$/
				if section
					self[section] = {} unless self[section]
					key = $1
					self[section][key] = true
				else
					key = $1
					self[key] = true
				end
			end
		end

		# handle substitutions (globals first)
		changes = true
		while changes do
			changes = false
			self.each_key do |k|
				next if self[k].is_a? Hash
				next unless self[k].is_a? String
				self[k].gsub!(/\$\((.+?)\)/) {|x|
					changes = true if self[$1]
					self[$1] || "$(#{$1})"
				}
			end
		end
		
		# handle substitutions within the sections
		changes = true
		while changes do
			changes = false
			self.each_key do |k|
				next unless self[k].is_a? Hash
				self[k].each_key do |j|
					next unless self[k][j].is_a? String
					self[k][j].gsub!(/\$\((.+?)\)/) {|x|
						changes = true if self[k][$1] || self[$1]
						self[k][$1] || self[$1] || "$(#{$1})"
					}
				end
			end
		end
	end
	
	def to_s
		str = ""
		# print globals first
		self.keys.sort.each do |k|
			next if self[k].is_a? Hash
			if self[k] === true
				str << "#{k}\n"
			else
				str << "#{k}: #{self[k]}\n"
			end
		end
		
		# now print the sections
		self.keys.sort.each do |k|
			next unless self[k].is_a? Hash
			str << "[#{k}]\n"
			self[k].keys.sort.each do |j|
				if self[k][j] === true
					str << "#{j}\n"
				else
					str << "#{j}: #{self[k][j]}\n"
				end
			end
		end
		str
	end
end