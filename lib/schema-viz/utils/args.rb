# frozen_string_literal: true

require './lib/schema-viz/utils/option'

module SchemaViz
  # parsing command line args
  # see also: https://ruby-doc.org/stdlib-2.4.2/libdoc/optparse/rdoc/OptionParser.html
  class Args
    attr_reader :command, :attributes, :arguments

    def initialize(command, attributes, arguments)
      @command, @attributes, @arguments = command, attributes, arguments
    end

    def has?(attr)
      attributes.key?(attr)
    end

    def get_s!(attr)
      value = attributes[attr]
      raise "#{attr.inspect} is not a String" unless value.instance_of?(String)
      value
    end

    def ==(other)
      self.class == other.class &&
        command == other.command &&
        attributes == other.attributes &&
        arguments == other.arguments
    end

    def self.parse(args)
      command = Option.empty
      attributes = {}
      arguments = []
      cur_attr = Option.empty
      cur_args = []
      args.each_with_index do |arg, index|
        if arg.start_with?('--')
          if cur_attr.some?
            if cur_args.empty?
              arguments.append(cur_attr.get!)
            else
              attributes[cur_attr.get!.to_sym] = cur_args.length == 1 ? cur_args.first : cur_args
            end
          end
          name, value = arg.delete_prefix('--').split('=')
          cur_attr = Option.of(name)
          cur_args = [value].compact
        elsif index.zero?
          command = Option.of(arg)
        elsif cur_attr.some?
          cur_args.append(arg)
        else
          arguments.append(arg)
        end
      end
      if cur_attr.some?
        if cur_args.empty?
          arguments.append(cur_attr.get!)
        else
          attributes[cur_attr.get!.to_sym] = cur_args.length == 1 ? cur_args.first : cur_args
        end
      end
      Args.new(command, attributes, arguments)
    end
  end
end
