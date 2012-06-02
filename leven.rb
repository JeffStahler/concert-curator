class HelperFunctions
	def self.levenshtein(a, b)
 	 	case
    	  when a.empty? then b.length
     	  when b.empty? then a.length
      	  else  [(a[0] == b[0] ? 0 : 1) + levenshtein(a[1..-1], b[1..-1]),
          	1 + levenshtein(a[1..-1], b),
          	1 + levenshtein(a, b[1..-1])].min
  		end
  	end
  	def self.percent_same(a,b)
  		1-(levenshtein(a,b).to_f/(a.length))
  	end


end