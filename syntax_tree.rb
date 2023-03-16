class Parser
  class SyntaxError < StandardError
  end

  def initialize(json_string)
    @json_string = json_string
    @index = 0
  end

  def current_char
    @json_string[@index]
  end

  def parse
    case @json_string[@index]
    when '{'
      parse_object
    when '['
      parse_array
    when '"'
      parse_string
    when 't'
      parse_true
    when 'f'
      parse_false
    when 'n'
      parse_null
    when /\d/
      parse_number
    when ' ', "\t", "\r", "\n"
      @index += 1
      parse
    end
  end

  def skip_whitespaces
    @index += 1 while current_char == ' ' || current_char == "\t" || current_char == "\r" || current_char == "\n"
  end

  def step
    @index += 1
  end

  def parse_object
    object = {}
    step
    while current_char != '}'
      skip_whitespaces
      key = parse_string
      raise SyntaxError, "expected ':'" unless current_char == ':'

      skip_whitespaces
      step
      skip_whitespaces

      value = parse
      object[key] = value
      raise SyntaxError, "expected ',' or '}'" unless current_char == ',' || current_char == '}'

      step if current_char == ','
    end
    step
    object
  end

  def parse_array
    array = []
    @index += 1
    while current_char != ']'
      array << parse
      raise SyntaxError, "expected ',' or ']'" unless current_char == ',' || current_char == ']'

      step if current_char == ','
    end
    step
    array
  end

  def parse_string
    @index += 1
    string = ''
    while current_char != '"'
      string << current_char
      @index += 1
    end
    @index += 1
    string
  end

  def parse_true
    raise SyntaxError, "expected 'true'" unless @json_string[@index..@index + 3] == 'true'

    @index += 4
    true
  end

  def parse_false
    raise SyntaxError, "expected 'false'" unless @json_string[@index..@index + 4] == 'false'

    @index += 5
    false
  end

  def parse_null
    raise SyntaxError, "expected 'null'" unless @json_string[@index..@index + 3] == 'null'

    @index += 4
    nil
  end

  def parse_number
    number = ''
    while current_char =~ /\d/
      number << current_char
      @index += 1
    end
    number.to_i
  end
end

# json_string = '["a", 1]'
json_strings = [
  '{"a": 1, "b": 2}',
  '{"a": null, "b": [1, 2, 3]}',
  '{"a": {"b": 1}, "c": 2}',
  '[1, 2, 3]',
  '[1, 2, [3, 4]]',
  '[{"test": "foo"}, 2, 3]'
]
json_strings.each do |json_string|
  parser = Parser.new(json_string)
  syntax_tree = parser.parse
  puts syntax_tree.inspect
end
