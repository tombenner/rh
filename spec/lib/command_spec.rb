require 'spec_helper'

describe Rh::Command do
  describe "#run" do
    before :each do
      allow_any_instance_of(described_class).to receive(:exit)
    end

    def should_open_url(url)
      expect(Launchy).to receive(:open).with(url)
    end

    def should_print_error_with(*strings)
      expect(STDERR).to receive(:puts) do |output|
        strings.each do |string|
          expect(output).to include(string)
        end
      end 
    end

    def run(arg)
      described_class.new([arg]).run
    end

    def core_url(path)
      "http://www.ruby-doc.org/core-#{Rh.ruby_version}/#{path}"
    end

    def stdlib_url(path)
      "http://www.ruby-doc.org/stdlib-#{Rh.ruby_version}/libdoc/#{path}"
    end

    context "classes and modules" do
      it "opens core URLs" do
        should_open_url(core_url('Array.html'))
        run('Array')
      end

      it "opens core URLs with namespaces" do
        should_open_url(core_url('GC/Profiler.html'))
        run('GC::Profiler')
      end

      it "opens stdlib URLs" do
        should_open_url(stdlib_url('json/rdoc/JSON.html'))
        run('JSON')
      end

      it "opens stdlib URLs with namespaces" do
        should_open_url(stdlib_url('benchmark/rdoc/Benchmark/Tms.html'))
        run('Benchmark::Tms')
      end

      context "nonexistent classes" do
        it "prints an error" do
          should_print_error_with('Class not found: Foo')
          run('Foo')
        end
      end
    end

    context "class methods separated by ::" do
      it "opens core URLs" do
        should_open_url(core_url('Regexp.html#method-c-quote'))
        run('Regexp::quote')
      end

      it "opens stdlib URLs" do
        should_open_url(stdlib_url('abbrev/rdoc/Abbrev.html#method-c-abbrev'))
        run('Abbrev::abbrev')
      end

      it "suggests" do
        should_open_url(stdlib_url('abbrev/rdoc/Abbrev.html#method-c-abbrev'))
        expect_any_instance_of(described_class).to receive(:puts)
        expect(STDIN).to receive(:gets).and_return('0')
        run('Array::abbrev')
      end
    end

    context "class methods separated by ." do
      it "opens core URLs" do
        should_open_url(core_url('Regexp.html#method-c-quote'))
        run('Regexp.quote')
      end

      it "opens stdlib URLs" do
        should_open_url(stdlib_url('abbrev/rdoc/Abbrev.html#method-c-abbrev'))
        run('Abbrev.abbrev')
      end

      it "suggests" do
        should_open_url(stdlib_url('abbrev/rdoc/Abbrev.html#method-c-abbrev'))
        expect_any_instance_of(described_class).to receive(:puts)
        expect(STDIN).to receive(:gets).and_return('0')
        run('Array.abbrev')
      end
    end

    context "instance methods" do
      it "opens core URLs" do
        should_open_url(core_url('Array.html#method-i-sort'))
        run('Array#sort')
      end

      it "opens stdlib URLs" do
        should_open_url(stdlib_url('abbrev/rdoc/Array.html#method-i-abbrev'))
        run('Array#abbrev')
      end

      it "suggests" do
        should_open_url(stdlib_url('abbrev/rdoc/Array.html#method-i-abbrev'))
        expect_any_instance_of(described_class).to receive(:puts)
        expect(STDIN).to receive(:gets).and_return('0')
        run('Abbrev#abbrev')
      end
    end

    context "methods" do
      context "methods with only one occurrence" do
        it "opens an ambiguous method name" do
          should_open_url(core_url('Enumerator.html#method-i-with_index'))
          run('with_index')
        end

        it "opens an exact method name" do
          should_open_url(core_url('Enumerator.html#method-i-with_index'))
          run('#with_index')
        end
      end

      context "methods with more than one occurrence" do
        it "gives suggestions for an ambiguous method name" do
          should_open_url(core_url('Array.html#method-i-sort'))
          expect_any_instance_of(described_class).to receive(:puts)
          expect(STDIN).to receive(:gets).and_return('0')
          run('sort')
        end

        it "gives suggestions for an exact method name" do
          should_open_url(core_url('Array.html#method-i-sort'))
          expect_any_instance_of(described_class).to receive(:puts)
          expect(STDIN).to receive(:gets).and_return('0')
          run('#sort')
        end
      end

      context "nonexistent methods" do
        it "prints an error" do
          should_print_error_with('Method not found: foo')
          run('foo')
        end
      end

      context "methods with special characters" do
        it "opens the escaped URL" do
          should_open_url(core_url('Array.html#method-i-sort-21'))
          run('sort!')
        end
      end
    end
  end
end