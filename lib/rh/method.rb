require 'cgi'

module Rh
  class Method
    include HasUrl

    attr_reader :klass, :name, :raw_name, :source, :package, :type, :version

    def initialize(options={})
      @klass = options['klass']
      @source = options['source']
      @package = options['package']
      @version = options['version']
      @name = options['name']
      match = name.match(/(#|::)(.+)/)
      raise "Invalid method name: #{name} in #{klass.name}" unless match
      @type = match[1] == '#' ? :instance : :class
      @raw_name = match[2]
    end

    def escaped_name
      CGI.escape(raw_name).gsub('%', '-')
    end

    def url
      type_string = type == :class ? 'c' : 'i'
      case source
      when 'core'
        "#{core_url}/#{klass.escaped_name}.html#method-#{type_string}-#{escaped_name}"
      when 'stdlib'
        "#{stdlib_url}/#{package}/rdoc/#{klass.escaped_name}.html#method-#{type_string}-#{escaped_name}"
      else
        raise 'Unable to generate URL'
      end
    end
  end
end
