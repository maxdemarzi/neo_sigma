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

  names = 500.times.collect{|x| generate_text}
  clusters = 5.times.collect{|x| {:r => rand(256),
                                  :g => rand(256),
                                  :b => rand(256)} }
  commands = []
  names.each_index do |n|
    cluster = clusters[n % clusters.size]
    commands << [:create_node, {:name => names[n], 
                                :size => 5.0 + rand(20.0), 
                                :r => cluster[:r],
                                :g => cluster[:g],
                                :b => cluster[:b],
                                :x => rand(600) - 300,
                                :y => rand(150) - 150
                                 }]
  end
 
  names.each_index do |from| 
    commands << [:add_node_to_index, "nodes_index", "type", "User", "{#{from}}"]
    connected = []

    # create clustered relationships
    members = 20.times.collect{|x| x * 10 + (from % clusters.size)}
    members.delete(from)
    rels = 3
    rels.times do |x|
      to = members[x]
      connected << to
      commands << [:create_relationship, "follows", "{#{from}}", "{#{to}}"]  unless to == from
    end    

    # create random relationships
    rels = 3
    rels.times do |x|
      to = rand(names.size)
      commands << [:create_relationship, "follows", "{#{from}}", "{#{to}}"] unless (to == from) || connected.include?(to)
    end

  end

  batch_result = neo.batch *commands
end

def nodes
  neo = Neography::Rest.new
  cypher_query =  " START node = node:nodes_index(type='User')"
  cypher_query << " RETURN ID(node), node"
  neo.execute_query(cypher_query)["data"].collect{|n| {"id" => n[0]}.merge(n[1]["data"])}
end  

def edges
  neo = Neography::Rest.new
  cypher_query =  " START source = node:nodes_index(type='User')"
  cypher_query << " MATCH source -[rel]-> target"
  cypher_query << " RETURN ID(rel), ID(source), ID(target)"
  neo.execute_query(cypher_query)["data"].collect{|n| {"id" => n[0], "source" => n[1], "target" => n[2]} }
end

get '/graph.xml' do
  neo = Neography::Rest.new
  @nodes = nodes  
  @edges = edges
  builder :graph
end
