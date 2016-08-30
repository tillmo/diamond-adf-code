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

def read_models(model_type,file)
  puts "Computing #{model_type} models"
  models = []
  IO.popen("go run diamond.go -c /usr/bin/clingo -#{model_type} #{file}").each_line do |line|
    models << to_model(line) if line  =~ /^[ftu]\(/
  end
  models
end

#main processing

if ARGV[0].nil?
  puts "Usage: models2dot.rb <file>"
  exit 1
end

if !File.exists?(ARGV[0])
  puts "#{ARGV[0]} not found"
  exit 1
end

models = read_models("adm",ARGV[0])

model_types = {"prf" => "peripheries=3", "grd" => "shape=octagon", "com" => "peripheries=2", "nai" => "color=blue", "mod" => "peripheries=4" }
models_hash = model_types.map{|mt,dot| [mt,dot,read_models(mt,ARGV[0])] }

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

dot = ARGV[0] + ".dot"
pdf = ARGV[0] + ".pdf"

File.open(dot,"w") do |f|
  f.puts "digraph G { rankdir=BT;" # grow upwards
  po.each do |m,superms|
    attrs = []
    models_hash.each do |mt,dot,models|
      if models.include?(m)
        attrs << dot
      end
    end
    attr = ""
    if !attrs.empty?
      attr = "["+attrs.sort.join(",")+"]"
    end
    f.puts m.to_s.quote + attr + ";"
    superms.each do |n|
      f.puts "#{m.to_s.quote} -> #{n.to_s.quote};"      
    end
  end
  f.puts "}"
end
puts "Written #{dot}"

system "dot -Tpdf #{dot} > #{pdf}"
puts "Written #{pdf}"


