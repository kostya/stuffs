require "uri"

class String
  def to_cgi
    URI.escape(self)
  end
end

struct Nil
  def to_cgi
    ""
  end
end

struct NamedTuple(T)
  def merge(**other)
    NamedTuple.new(**self, **other)
  end
end

def every(time, &block)
  spawn do
    sleep(rand(time.to_f))
    loop do
      block.call
      sleep(time)
    end
  end
end

module Enumerable(T)
  def parallel_map(&block : T -> U)
    map { |e| future { block.call(e) } }.map &.get
  end
end

class String
  def rus_downcase
    self.downcase.tr("ЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЁЯЧСМИТЬБЮ", "йцукенгшщзхъфывапролджэёячсмитьбю")
  end
end

TABLE_FOR_ESCAPE_HTML__ = {
  "&"  => "&amp;",
  "\"" => "&quot;",
  "<"  => "&lt;",
  ">"  => "&gt;",
}

def ruby_escapeHTML(string)
  string.gsub(/[&\"<>]/, TABLE_FOR_ESCAPE_HTML__)
end

def ruby_unescapeHTML(string)
  string.gsub(/&(amp|quot|gt|lt|\#[0-9]+|\#x[0-9A-Fa-f]+);?/) do
    match = $1.to_s
    case match
    when "amp"  then "&"
    when "quot" then "\""
    when "gt"   then ">"
    when "lt"   then "<"
    when /\A#0*(\d+)\z/
      n = $1.to_i
      n.chr
    when /\A#x([0-9a-f]+)\z/i
      n = $1.to_s.to_i(16)
      n.chr
    else
      "&#{match};"
    end
  end
end

macro include_constants(type)
  {% for constant in type.resolve.constants %}
    {{constant}} = {{type}}::{{constant}}
  {% end %}
end

class URI
  # URL-encode a string into a URI safe structure
  def self.escape_uri_safe(string : String) : String
    String.build { |io| escape2(string, io, false, true) { |byte| byte } }
  end

  # URL-encode a string and write the result to an `IO`.
  #
  # This method requires block.
  private def self.escape2(string : String, io : IO, space_to_plus = false, uri_safe = false, &block)
    string.each_byte do |byte|
      char = byte.unsafe_chr
      if char == ' ' && space_to_plus
        io.write_byte '+'.ord.to_u8
      elsif reserved?(byte) && uri_safe
        io.write_byte byte
      elsif char.ascii? && yield(byte) && (!space_to_plus || char != '+')
        io.write_byte byte
      else
        io.write_byte '%'.ord.to_u8
        io.write_byte '0'.ord.to_u8 if byte < 16
        byte.to_s(io, 16, upcase: true)
      end
    end
    io
  end
end
