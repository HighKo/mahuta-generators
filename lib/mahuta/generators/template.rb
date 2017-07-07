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

require 'cite'

module Mahuta::Generators
  
  module Template
    
    def render(name, node = nil, locals = {})
      t = Cite.file(template_root + "#{name}.cite")
      locals = locals.merge(node: node) if node
      t.render(self, locals)
    end
    
    def render_all(name, nodes, options = {})
      options[:locals] ||= {}
      options[:with_joint] ||= ''
      nodes.collect {|n| render(name, n, options[:locals]) }.join options[:with_joint]
    end
    
  end
  
end
