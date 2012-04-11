require 'rubygems'
require 'neography'
require 'sinatra'
require 'uri'
require 'builder'

def generate_text(length=8)
  chars = 'abcdefghjkmnpqrstuvwxyz'
  key = ''
  length.times { |i| key << chars[rand(chars.length)] }
  key
end

def create_graph
  neo = Neography::Rest.new
  graph_exists = neo.get_node_properties(1)
  return if graph_exists && graph_exists['name']

  names = 200.times.collect{|x| generate_text}
  clusters = 5.times.collect{|x| {:r => rand(256),
                                  :g => rand(256),
                                  :b => rand(256)} }
  commands = []
  names.each_index do |n|
    cluster = clusters[n % clusters.size]
    commands << [:create_node, {:name => names[n], 
                                :size => 15.0 + rand(10.0), 
                                :r => cluster[:r],
                                :g => cluster[:g],
                                :b => cluster[:b],
                                :x => rand(600) - 300,
                                :y => rand(150) - 150
                                 }]
  end
 
  names.each_index do |x| 
    commands << [:add_node_to_index, "nodes_index", "type", "User", "{#{x}}"]
    follows = names.size.times.map{|y| y}
    follows.delete_at(x)
    follows.sample(rand(10)).each do |f|
      commands << [:create_relationship, "follows", "{#{x}}", "{#{f}}"]    
    end
  end

  batch_result = neo.batch *commands
end

def nodes
  neo = Neography::Rest.new
  cypher_query =  " START n = node:nodes_index(type='User')"
  cypher_query << " RETURN ID(n), n"
  neo.execute_query(cypher_query)["data"].collect{|n| {"id" => n[0]}.merge(n[1]["data"])}
end  

get '/follows' do
  follower_matrix.map{|fm| {"name" => fm[0], "follows" => fm[1][1..(fm[1].size - 2)].split(", ")} }.to_json
end

get '/graph.xml' do
  neo = Neography::Rest.new
  @nodes = nodes  
  puts @nodes.inspect   
  builder :graph
end
