class XMLDocImporter
  def initialize(xml_string, xpath_prefix = '')
    @xml_doc = Nokogiri::XML(xml_string)
    @namespaces = @xml_doc.collect_namespaces
    @xpath_prefix = xpath_prefix
  end

  def attribute_from_xpath(xpath, &transformation)
    full_xpath = @xpath_prefix + xpath
    nodes = @xml_doc.xpath(full_xpath, @namespaces)

    if nodes.length == 1
      data = XMLDocImporter.get_content_from_node(nodes.first)
    elsif nodes.length > 1
      data = nodes.collect {|node| XMLDocImporter.get_content_from_node(nodes.first)}
    end

    if data && transformation
      data = transformation.call(data)
    end

    data
  end

  def self.get_content_from_node(node)
    if node.respond_to?(:children)
      if node.children.count == 1
        data = node.try(:content)
      elsif node.children.count > 1
        data = XMLDocImporter.node_to_hash(node)
      end
    end
  end

  def self.node_to_hash(node)
    hash = {}
    if node.children.count > 1
      hash[node.name] = node.children.collect { |child_node| XMLDocImporter.node_to_hash(child_node) }
    else
      hash[node.name] = node.try(:content)
    end
    hash
  end
end
