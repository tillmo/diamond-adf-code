#!/usr/bin/ruby

require 'set'
#require 'tsort'

class Set
  def to_s
    map(&:to_s).join(",")
  end
end

class String
  def quote
    '"' + self + '"'
  end
end

def to_model(s)
  model = s.split(" ").select do |a|
    a[0]!="u"
  end.map do |a|
    a.gsub("f(","-").gsub("t(","").gsub(")","")
  end
  Set.new model
end

models = []
STDIN.each do |line|
  models << to_model(line) if line  =~ /^[ftu]\(/
end

# compute partial order on models explicitly
po = {}
models.each do |m|
  po[m] = Set.new(models.select{|n| m!=n and m.subset?(n)})
end

#puts po.inspect

# compute intransitive kernel
po.each do |m,superms|
  removal_set = Set.new
  superms.each do |n|
    po[n].each do |o|
      if superms.include?(o) then
        removal_set.add(o)
      end
    end
  end
  if !removal_set.empty?
    po[m] = po[m].difference(removal_set)
  end
end

#puts po.inspect

puts "digraph G {"

po.each do |m,superms|
  puts m.to_s.quote + ";"
  superms.each do |n|
    puts "#{m.to_s.quote} -> #{n.to_s.quote};"      
  end
end

puts "}"


