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

    def kotlin_type(type, many = nil)
      case many
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
        'Int'
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
      when :guid, :uuid
        'UUID'
      when :structured_data
        'Hash'
      else
        kotlin_class_name(type)
      end
    end

    def kotlin_class_name(type)
        type.to_s.camelize(:upper)
    end

    def kotlin_file_name(name) 
      "#{kotlin_type_name(name)}.kt"
    end
    
    def kotlin_directory(namespace)
      File.join(namespace.collect {|nc| nc.to_s.camelize(:lower) })
    end

    def kotlin_namespace(namespace)
      namespace.collect {|nc| nc.to_s.camelize(:lower) }.join('.')
    end
    
    def kotlin_full_qualified_type(namespace, type)
      [kotlin_namespace(namespace), kotlin_class_name(type)].join('.')
    end
    
    def kotlin_variable_name(name)
      name.to_s.camelize(:lower)
    end

    def kotlin_constant_name(name)
      name.to_s.upcase
    end

  end

end
