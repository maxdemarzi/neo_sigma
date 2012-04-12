xml.instruct! :xml
xml.gexf 'xmlns' => "http://www.gephi.org/gexf", 'xmlns:viz' => "http://www.gephi.org/gexf/viz"  do
  xml.graph 'defaultedgetype' => "directed", 'idtype' => "string", 'type' => "static" do
    xml.nodes :count => @nodes.size do
      @nodes.each do |n|
        xml.node :id => n["id"], :label => n["name"] do
	   xml.tag!("viz:size", :value => n["size"])
	   xml.tag!("viz:color", :b => n["b"], :g => n["g"], :r => n["r"])
	   xml.tag!("viz:position", :x => n["x"], :y => n["y"]) 
	 end
      end
    end
    xml.edges :count => @edges.size do
      @edges.each do |e|
        xml.edge:id => e["id"], :source => e["source"], :target => e["target"] 
      end
    end
  end
end
