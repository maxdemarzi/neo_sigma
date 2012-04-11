xml.instruct! :xml
xml.gexf 'xmlns' => "http://www.gephi.org/gexf", 'xmlns:viz' => "http://www.gephi.org/gexf/viz"  do
  xml.graph 'defaultedgetype' => "directed", 'idtype' => "string", 'type' => "static" do
	xml.nodes do
	  @nodes.each do |n|
	    xml.node :id => n["id"], :label => n["name"] do
	      xml.tag!("viz:size", :value => n["size"])
	      xml.tag!("viz:color", :b => n["b"], :g => n["g"], :r => n["r"])
	      xml.tag!("viz:position", :x => n["x"], :y => n["y"]) 
	    end
	  end
	end
  end
end
#      xml.attvalues do
#        xml.attvalue :for => "authority" :value => n["authority"]
#        xml.attvalue :for => "hub" :value => n["hub"]
#      end