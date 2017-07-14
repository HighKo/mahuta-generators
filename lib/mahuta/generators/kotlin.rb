# encoding: UTF-8
# Copyright 2017 Max Trense
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#   http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module Mahuta::Generators

  module Kotlin

    def kotlin_type(node)
      type = node[:type]
      case node[:many]
      when nil, false
        kotlin_type_name(type)
      when true, :unordered
        "Set<#{kotlin_type_name(type)}>"
      when :ordered
        "List<#{kotlin_type_name(type)}>"
      end
    end

    def kotlin_type_name(type)
      case type
      when :bool, :boolean
        'Boolean'
      when :int, :integer
        'Integer'
      when :float
        'Float'
      when :long, :long_integer
        'Long'
      when :string, :email, :phone_number
        'String'
      when :url
        'URL'
      when :date
        'org.joda.time.DateTime'
      when :binary
        'ByteArray'
      else
        kotlin_class_name(type)
      end
    end

    def is_builtin?(type)
      case type
      when :bool, :boolean, :int, :integer, :float, :long, :long_integer, :string, :email, :phone_number, :url, :date, :binary
        true
      else
        false
      end
    end

    def is_primitive?(type)
      case type
      when :bool, :boolean, :int, :integer, :float, :long, :long_integer, :string, :email, :phone_number 
        true
      else
        false
      end
    end

    def kotlin_class_name(type)
        type.to_s.camelize(:upper)
    end

    def kotlin_namespace(node, *postfixes)
      [ *node.namespace, *postfixes ].collect {|nc| nc.to_s.camelize(:lower) }.join('.')
    end

    def kotlin_variable_name(name)
      name.to_s.camelize(:lower)
    end

    def kotlin_constant_name(name)
      name.to_s.upcase
    end

    def kotlin_serializer_function(node) 
      if is_builtin? node.type 
        'toString' 
      else 
        'toJson'
      end
    end

    def kotlin_json_adder_function(node)
      if is_builtin? node.type 
        'addProperty' 
      else 
        'add'
      end
    end

    def kotlin_deserializer_function(node) 
      if is_builtin? node.type 
        'fromString' 
      else 
        'fromJson' 
      end
    end

    def kotlin_json_fetcher_function(node)
      type = node.type

      return 'asObject' unless is_builtin?(type)

      case node.type
      when :bool, :boolean
        'asBoolean'
      when :int, :integer
        'asInteger'
      when :float
        'asFloat'
      when :long, :long_integer
        'asLong'
      when :string, :email, :phone_number, :url, :date, :binary
        'asString'
      end
    end

    def find_type_node_for(node)
        node
          .root
          .descendants {|descendant|
            descendant.name == node.type && descendant&.is_value_type? rescue false
          }
          .first
    end

    def kotlin_import(node)
      return nil if is_builtin? node.type 

      type_node = find_type_node_for(node)

      unless type_node.respond_to? :namespace 
        raise <<-EOF.strip_heredoc
          Can't infer namespace for #{node.node_type.to_s}:#{node.name.to_s} of type #{type_node.name.to_s}
          while generating #{node.parent.node_type.to_s}:#{node.parent.name.to_s}.
          Maybe you used a property name as type?
        EOF
      end

      kotlin_namespace(type_node) + '.' + kotlin_class_name(type_node.name)
    end

    def kotlin_file_name(node) 
      "#{kotlin_type_name(node[:name])}.kt"
    end

  end

end
