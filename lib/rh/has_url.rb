module Rh
  module HasUrl
    def core_url
      "http://www.ruby-doc.org/core-#{version}"
    end

    def stdlib_url
      "http://www.ruby-doc.org/stdlib-#{version}/libdoc"
    end
  end
end
