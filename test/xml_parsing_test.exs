defmodule XmlParsingTest do
    @moduledoc """
    从xmerl模块头文件中提取XML元素记录
    `from_lib`指明的路径是在Erlang库模块的路径, 本例中`xmerl.hrl`的路径如下所示, 本来示例是在Mac OS下通过MacPorts系统安装后的路径, Linux下的路径请自行寻找

    我们要提取的两个记录在xmerl.hrl中的定义分别为
    - xmlElement
        ```
        -record(xmlElement,{
          name,         % atom()
          expanded_name = [],   % string() | {URI,Local} | {"xmlns",Local}
          nsinfo = [],          % {Prefix, Local} | []
          namespace=#xmlNamespace{},
          parents = [],     % [{atom(),integer()}]
          pos,          % integer()
          attributes = [],  % [#xmlAttribute()]
          content = [],
          language = "",    % string()
          xmlbase="",           % string() XML Base path, for relative URI:s
          elementdef=undeclared % atom(), one of [undeclared | prolog | external | element]
         }).
        ```
    - xmlText
        ```
        -record(xmlText,{
          parents = [], % [{atom(),integer()}]
          pos,      % integer()
          language = [],% inherits the element's language
          value,    % IOlist()
          type = text   % atom() one of (text|cdata)
         }).
        ```
    """
    use ExUnit.Case
    require Record
    Record.defrecord :xmlElement, Record.extract(:xmlElement, from_lib: "xmerl/include/xmerl.hrl")
    Record.defrecord :xmlText, Record.extract(:xmlText, from_lib: "xmerl/include/xmerl.hrl")

    def sample_xml do
      """
      <blog>
          <title>Using xmerl module to parse xml document in elixir</title>
      </blog>
      """
    end

    test "Test parsing xml document" do
        {document, _} = :xmerl_scan.string(String.to_char_list(sample_xml))
        [element] = :xmerl_xpath.string('/blog/title/text()', document)
        assert xmlText(element, :value)  == 'Using xmerl module to parse xml document in elixir'
    end
end