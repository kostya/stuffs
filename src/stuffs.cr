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
