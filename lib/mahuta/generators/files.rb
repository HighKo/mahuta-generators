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

require 'diff/lcs'
require 'diffy'
require 'pastel'
require 'tty-prompt'

module Mahuta::Generators
  
  module Files
    
    P = Pastel.new
    
    def initialize(options = {})
      super
      @target = options[:target] || raise("Files generator needs to know a target directory")
    end
    
    attr_reader :target
    
    def update_file(name, content)
      print "Generating file #{name.relative_path_from(@target)}... "
      if name.exist?
        diff = Diffy::Diff.new(name.read, content)
        if diff.to_s.empty?
          puts P.bright_yellow("skip")
        else
          puts P.bold.yellow("update")
        end
      else
        puts P.bold.green("create")
      end
      name.parent.mkpath
      name.write(content)
    end
    
  end
  
end
