require 'json'
require 'launchy'

module Rh
  class Command
    def initialize(args)
      @args = args
      @version = Rh.ruby_version
    end

    def run
      if @args.empty?
        exit_with_error("Please provide an argument:\n$ rh Array#shift") and return
      end
      if @args.length > 1
        exit_with_error("Too many arguments!") and return
      end

      arg = @args.first.strip
      show(arg)
    end

    private

    def show(arg)
      class_pattern = '[A-Z][\w]+(?:\:\:[A-Z][\w]+)*'
      method_pattern = '[^A-Z\s]+'
      case arg
      when /^(#{class_pattern})$/
        show_class($1)
      when /^(#{class_pattern})((?:\.|::|#)#{method_pattern})$/
        show_class_method($1, normalize_method($2))
      # when /^((?:\.|::|#)#{method_pattern})$/
      #   show_method(normalize_method($2))
      when /^(#{method_pattern})$/
        show_method(normalize_method($1))
      else
        exit_with_error("Invalid pattern: #{arg}")
      end
    end

    def exit_with_error(message)
      STDERR.puts message
      exit 1
      true
    end

    def show_class(class_name)
      klass = klasses[class_name]
      unless klass
        exit_with_error("Class not found: #{class_name}") and return
      end
      show_url(klass.url)
    end

    def show_class_method(class_name, method_name)
      klass = klasses[class_name]
      unless klass
        exit_with_error("Class not found: #{class_name}") and return
      end
      method = klass.find_method_by_name(method_name)
      unless method
        suggested_methods = []
        klasses.values.each do |klass|
          method = klass.find_method_by_name(method_name)
          suggested_methods << method if method
        end
        unless suggested_methods.empty?
          suggested_methods = suggested_methods.sort_by { |method| [method.klass.name, method.name] }
          urls = suggested_methods.map(&:url)
          suggestions = suggested_methods.map.with_index do |method, index|
            "#{method.klass.name}#{method.name}"
          end
          show_suggestions(urls, suggestions)
          return
        end
        message = "Method not found: #{class_name}#{method_name}"
        exit_with_error(message) and return
      end
      show_url(method.url)
    end

    def show_method(method_name)
      normalize_method(method_name)
      suggested_methods = []
      klasses.values.each do |klass|
        methods = klass.find_methods_by_ambiguous_name(method_name)
        methods.each do |method|
          suggested_methods << method
        end
      end
      if suggested_methods.length == 1
        show_url(suggested_methods.first.url)
        return
      end
      if suggested_methods.length == 0
        exit_with_error("Method not found: #{method_name}") and return
      end
      suggested_methods = suggested_methods.sort_by { |method| [method.klass.name, method.name] }
      urls = suggested_methods.map(&:url)
      suggestions = suggested_methods.map.with_index do |method, index|
        "#{method.klass.name}#{method.name}"
      end
      show_suggestions(urls, suggestions)
    end

    def show_suggestions(urls, suggestions)
      numbered_suggestions = suggestions.map.with_index do |suggestion, index|
        "#{index.to_s.rjust(3, ' ')}. #{suggestion}"
      end
      puts "Did you mean?\n#{numbered_suggestions.join("\n")}\nEnter a number:"
      while (chosen_index = STDIN.gets)
        break
      end
      chosen_index = chosen_index.chomp.gsub(/[^\d]/, '')
      if chosen_index.empty?
        exit_with_error("Invalid choice!") and return
      end
      url = urls[chosen_index.to_i]
      unless url
        exit_with_error("Invalid choice!") and return
      end
      show_url(url)
    end

    def show_url(url)
      Launchy.open(url)
    end

    def normalize_method(method_name)
      if method_name.start_with?('.')
        method_name.sub!('.', '::')
      end
      method_name
    end

    def klasses
      @klasses ||= begin
        path = "#{File.dirname(File.absolute_path(__FILE__))}/data/classes.json"
        content = File.read(path)
        class_names_to_klasses = JSON.load(content)
        class_names_to_klasses = class_names_to_klasses.map do |class_name, klass|
          [class_name, Rh::Klass.new(klass.merge('name' => class_name, 'version' => @version))]
        end
        Hash[class_names_to_klasses]
      end
    end
  end
end
