require 'csv'
require 'bio-samtools'


class Bio::DB::Faidx

	class Entry
		attr_accessor :name, :length, :offset, :linebases, :linewidth
	end
	def initialize(opts)
		@cache = false
		@cache = opts[:cache] if opts[:cache]
		@filename = opts[:filename]
		@inited = false
	end

	def init_cache
		@inited = true
		@entries = Hash.new
		@entries_order = Array.new
		read_entries do |e|
			@entries[e.name] = e
			@entries_order << e.name 
		end
	end

	def entries
		init_cache unless @inited
		@entries
	end

	def [](entry)
		init_cache unless @inited
	 @entries[entry]
	end
	

	def entries_order
		init_cache unless @inited
		return @entries_order
	end

	def read_entries
		CSV.foreach(@filename, :col_sep => "\t", :skip_lines=>/^#/, :skip_blanks=>true) do |row|
		fasta_entry = Bio::DB::Faidx::Entry.new
		[:name, :length, :offset, :linebases, :linewidth].each_with_index do |sym, i|
			answer = row[i]
			answer = answer.to_i if [:length, :offset, :linebases, :linewidth].include?(sym)
			fasta_entry.send("#{sym}=".to_sym, answer)
			yield fasta_entry
		end
	end

	def each_entry
		unless @cache
			read_entries { |e| yield e }
		else
			entries_order.each { |e|  yield @entries[e] }
		end
	end
end


class Bio::DB::Fasta::Region
	def overlaps (other)
		return false if other.entry != @entry
		return true if other.start >= @start and other.start <= @end
		return true if other.end   >= @start and other.end   <= @end
		return false
	end

	def subset (other)
		return false if other.entry != @entry
		return true if other.start >= @start and other.end <= @end
	end

	def joinRegion (other)
		return nil unless self.overlaps(other)
		out = self.clone 
		out.start = other.start if other.start < out.start
		out.end = other.end if other.end > out.end
		return out 
	end

	def overlap_in_set(set) 
		overlap_set = Set.new 
		set.each do |e| 
			overlap_set << e if self.overlaps(e)
		end
		overlap_set
	end
end
	#class Faidx
	class Entry
		attr_accessor :name, :length, :offset, :linebases, :linewidth
	end
	def initialize(opts)
		@cache = false
		@cache = opts[:cache] if opts[:cache]
		@filename = opts[:filename]
		@inited = false
	end

	def init_cache
		@inited = true
		@entries = Hash.new
		@entries_order = Array.new
		read_entries do |e|
			@entries[e.name] = e
			@entries_order << e.name 
		end
	end

	def entries
		init_cache unless @inited
		@entries

	end

	def entries_order
		init_cache unless @inited
		return @entries_order
	end

	def read_entries
		CSV.foreach(@filename, :col_sep => "\t", :skip_lines=>/^#/, :skip_blanks=>true) do |row|
		fasta_entry = Bio::DB::Faidx::Entry.new
		[:name, :length, :offset, :linebases, :linewidth].each_with_index do |sym, i|
			answer = row[i]
			answer = answer.to_i if [:length, :offset, :linebases, :linewidth].include?(sym)
			fasta_entry.send("#{sym}=".to_sym, answer)
			yield fasta_entry
		end
	end

	def each_entry
		unless @cache
			read_entries { |e| yield e }
		else
			entries_order.each { |e|  yield @entries[e] }
		end
	end
end
end

class Bio::DB::Fasta::Region
	def overlaps (other)
		return false if other.entry != @entry
		return true if other.start >= @start and other.start <= @end
		return true if other.end   >= @start and other.end   <= @end
		return false
	end

	def subset (other)
		return false if other.entry != @entry
		return true if other.start >= @start and other.end <= @end
	end

	def joinRegion (other)
		return nil unless self.overlaps(other)
		out = self.clone 
		out.start = other.start if other.start < out.start
		out.end = other.end if other.end > out.end
		return out 
	end

	def overlap_in_set(set) 
		overlap_set = Set.new 
		set.each do |e| 
			overlap_set << e if self.overlaps(e)
		end
		overlap_set
	end
end