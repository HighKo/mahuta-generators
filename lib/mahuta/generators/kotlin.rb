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

    def kotlin_imports(node) 
      node 
        .children(:property)
        .select {|prop|
          if prop.respond_to? :is_standard? 
            !prop.is_standard?
          else 
            false
          end
        }
        .uniq {|prop| prop.type}
        .collect {|prop| "import " + kotlin_import(prop)}
        .join "\n"
    end

    def kotlin_import(node)
      type_node =
        node
          .root
          .descendants {|descendant|
            descendant.name == node.type 
          }
          .first

      unless type_node.respond_to? :namespace 
        raise <<-EOF.strip_heredoc
          Can't infer namespace for #{node.node_type.to_s}:#{node.name.to_s} of type #{type_node.name.to_s}
          while generating #{node.parent.node_type.to_s}:#{node.parent.name.to_s}.
          Maybe you used a property name as type?
        EOF
      end

      kotlin_namespace(type_node) + '.' + kotlin_class_name(type_node.name)
    end

    def kotlin_collection_imports(node) 
      collection_properties =
        node
          .children(:property)
          .select {|prop| prop[:many]} 

      return nil if collection_properties.empty?
      
      if collection_properties.all? {|prop| prop[:many] == :ordered}
        'import kotlin.colletions.List'
      elsif collection_properties.any? {|prop| prop[:many] == :ordered}
        "import kotlin.colletions.List\nimport kotlin.colletions.Set"
      else
        'import kotlin.colletions.Set'
      end
    end

    def path_for_type(node)
      ns = node.namespace.collect {|nc| nc.to_s.camelize(:lower) }
      target + [*ns, "#{kotlin_type_name(node[:name])}.kt"].collect(&:to_s).join('/')
    end

    def kotlin_file_name(node) 
      "#{kotlin_type_name(node)}.kt"
    end

  end

end
