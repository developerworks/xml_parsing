defmodule Weather do
  require Record
  use HTTPoison.Base
  Record.defrecord :xmlElement, Record.extract(:xmlElement, from_lib: "xmerl/include/xmerl.hrl")
  Record.defrecord :xmlText, Record.extract(:xmlText, from_lib: "xmerl/include/xmerl.hrl")

  def parse_url(url) do
    {:ok, response} = HTTPoison.get(url)
    { xml, _rest} = :xmerl_scan.string :erlang.bitstring_to_list(response.body)
    nodes = :xmerl_xpath.string('/current_observation/*', xml)
    { response, xml, nodes }
  end

  def parse_nodes(nodes) do
    Enum.reduce nodes, Map.new, fn(node, accum) ->
      name = Atom.to_string(node.name)
      [text_node] = node.content
      Map.put(accum, name, text_node.value)
    end
  end
  def build_map_from(url) do
    {_response, _xml, nodes} = parse_url(url)
    nodes
    parse_nodes(nodes)
  end
end
