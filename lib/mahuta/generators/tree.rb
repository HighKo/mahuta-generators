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
  
  module Tree
    
    def initialize(options = {})
      @result = options.delete(:result) || Mahuta::Node.new(nil, nil, :root)
      @stack = [@result]
      super
    end
    
    attr_reader :result
    attr_reader :stack
    
    def top
      @stack.last
    end
    
    def child(node_type, attributes = {})
      top.add_child(node_type, attributes)
    end
    
    def child!(node_type, attributes = {})
      new_child = child(node_type, attributes)
      stack.push new_child
      new_child
    end
    
  end
  
end
