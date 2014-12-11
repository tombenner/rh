require 'rh/has_url'

module Rh
  class Klass
    include HasUrl

    attr_reader :name, :source, :packages, :version

    def initialize(options={})
      @name = options['name']
      @source = options['source']
      @version = options['version']
      @packages = options['packages']
      @options = options
    end

    def escaped_name
      name.gsub('::', '/')
    end

    def url
      case source
      when 'stdlib'
        "#{stdlib_url}/#{packages.first}/rdoc/#{escaped_name}.html"
      when 'core'
        "#{core_url}/#{escaped_name}.html"
      else
        raise 'Unable to generate URL'
      end
    end

    def find_method_by_name(method_name)
      methods.find { |method| method.name == method_name }
    end

    def find_methods_by_ambiguous_name(ambiguous_method_name)
      if ambiguous_method_name.start_with?('#') || ambiguous_method_name.start_with?('::')
        methods.select { |method| method.name == ambiguous_method_name }
      else
        methods.select { |method| method.raw_name == ambiguous_method_name }
      end
    end

    def methods
      @methods ||= begin
        @options['methods'].map do |method|
          Rh::Method.new(method.merge('klass' => self, 'version' => version))
        end
      end
    end
  end
end
