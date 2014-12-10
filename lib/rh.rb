directory = File.dirname(File.absolute_path(__FILE__))
Dir.glob("#{directory}/rh/*.rb") { |file| require file }

module Rh
  def self.ruby_version
    RUBY_VERSION
  end
end
