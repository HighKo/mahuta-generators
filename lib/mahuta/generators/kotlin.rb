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
        'DateTime'
      when :binary
        'ByteArray'
      when :guid
        'UUID'
      when :structured_data
        'JsonElement'
      else
        kotlin_class_name(type)
      end
    end

    def is_builtin?(type)
      case type
      when :bool, :boolean, :int, :integer, :float, :long, :long_integer, :string, :email, :phone_number, :url, :date, :binary, :guid, :structured_data
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

    def is_extern?(type)
      case type
      when :date, :guid, :structured_data
        true
      else 
        false
      end
    end

    def fully_qualified_extern(type)
      case type
      when :date
        'org.joda.time.DateTime'
      when :guid
        'java.util.UUID'
      when :structured_data
        'com.google.gson.JsonElement'
      end
    end

    def kotlin_class_name(type)
        type.to_s.camelize(:upper)
    end

    def kotlin_namespace(node)
      node.namespace.collect {|nc| nc.to_s.camelize(:lower) }.join('.')
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
      when :string, :email, :phone_number, :url, :date, :binary, :guid
        'asString'
      end
    end

    def find_type_node_for(node, scope = nil)
      if scope.nil?
        # if not given scope, look it up in all namespaces
        node
          .root
          .descendants(:namespace).flat_map {|ns|
            find_type_node_for(node, ns)
          }
          .first
      else
        type_node = scope
          .descendants {|descendant|
            descendant.name == node.type && descendant&.is_value_type? rescue false
          }
          .first

        if type_node.nil? 
          # fallback to search in all namespaces
          # mostly useful for types defined in "common" or "shared" namespaces
          find_type_node_for(node)
        else
          type_node
        end
      end
    end

    def scope(node, type, name = nil) 
      if name.nil?
        # reference: search scope upwards from node
        node.ascendants {|p| p.node_type == type}.first
      else
        # foreign: search scope downwards from root
        node.root.descendants {|c| c.node_type == type && node.name == name}.first
      end
    end

    def kotlin_import(node, scope = nil)
      return fully_qualified_extern(node.type) if is_extern? node.type 
      return nil if is_builtin? node.type 

      # by default, lookup the import in the node's aggregate
      scope ||= scope(node, :aggregate)
      type_node = find_type_node_for(node, scope)

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
