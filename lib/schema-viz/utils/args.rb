# frozen_string_literal: true

module SchemaViz
  # parsing command line args
  # see also: https://ruby-doc.org/stdlib-2.4.2/libdoc/optparse/rdoc/OptionParser.html
  class Args
    attr_reader :command, :attributes, :arguments

    def initialize(command = nil, attributes = {}, arguments = [])
      @command = command
      @attributes = attributes
      @arguments = arguments
    end

    def has?(attr)
      attributes.key?(attr)
    end

    def get_s(attr)
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
      command = nil
      attributes = {}
      arguments = []
      cur_attr = nil
      cur_args = []
      args.each_with_index do |arg, index|
        if arg.start_with?('--')
          unless cur_attr.nil?
            if cur_args.empty?
              arguments.append(cur_attr)
            else
              attributes[cur_attr.to_sym] = cur_args.length == 1 ? cur_args.first : cur_args
            end
          end
          cur_attr = arg.delete_prefix('--')
          cur_args = []
        elsif index.zero?
          command = arg
        elsif !cur_attr.nil?
          cur_args.append(arg)
        else
          arguments.append(arg)
        end
      end
      unless cur_attr.nil?
        if cur_args.empty?
          arguments.append(cur_attr)
        else
          attributes[cur_attr.to_sym] = cur_args.length == 1 ? cur_args.first : cur_args
        end
      end
      Args.new(command, attributes, arguments)
    end
  end
end
