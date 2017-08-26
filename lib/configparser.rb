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
			next if (line =~ /^\s*(#|;)/)
			
			# parse out the lines of the config
			if line =~ /^\s*(.+?)\s*[=:]\s*(.*)$/ # handle key=value lines
				if section
					self[section] = {} unless self[section]
					key = $1
          if self[section][key]
            self[section][key] = [self[section][key]] unless self[section][key].is_a?(Array)
            self[section][key] << $2
          else
            self[section][key] = $2
          end
				else
					key = $1
          if self[key]
            self[key] = [self[key]] unless self[key].is_a?(Array)
            self[key] << $2
          else
            self[key] = $2
          end
				end
			elsif line =~ /^\s*\[(.+?)\]/ # handle new sections
				section = $1
        self[section] = {} unless self[section]
			elsif line =~ /^\s+(.+?)$/ # handle continued lines
				if section
          if self[section][key].is_a?(Array)
            self[section][key].last << " #{$1}";
          else
            self[section][key] << " #{$1}";
          end
				else
          if self[key].is_a?(Array)
            self[key].last << " #{$1}"
          else
            self[key] << " #{$1}"
          end
				end
			elsif line =~ /^([\w\d\_\-]+)$/
				if section
					self[section] = {} unless self[section]
					key = $1
          if self[section][key]
            self[section][key] = [self[section][key]] unless self[section][key].is_a?(Array)
            self[section][key] << true
          else
            self[section][key] = true
          end
				else
					key = $1
          if self[key]
            self[key] = [self[key]] unless self[key].is_a?(Array)
            self[key] << true
          else
            self[key] = true
          end
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
	
	def to_s(sep=':')
		str = ""
		# print globals first
		self.keys.sort.each do |k|
			next if self[k].is_a? Hash
      if not self[k].is_a?(Array)
        self[k] = [self[k]]
      end
      self[k].each do |v|
			  if v === true
				  str << "#{k}\n"
        elsif v == ""
          str << "#{k}#{sep}\n"
			  else
				  str << "#{k}#{sep} #{v}\n"
			  end
      end
		end
		
		# now print the sections
		self.keys.sort.each do |k|
      next unless self[k].is_a? Hash
      str << "[#{k}]\n"
      self[k].sort.each do |j,v|
        if not v.is_a?(Array)
          v = [v]
        end
			  v.each do |v2|
				  if v2 === true
					  str << "#{j}\n"
          elsif v2 == ""
            str << "#{j}#{sep}\n"
				  else
				    str << "#{j}#{sep} #{v2}\n"
				  end
        end
			end
		end
		str
	end
end