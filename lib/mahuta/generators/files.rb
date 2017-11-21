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
      @target = Pathname(options.delete(:target) || raise("Files generator needs to know a target directory"))
      @diff = options.include?(:diff) ? options.delete(:diff) : true
      @current_destination = []
      super
    end
    
    attr_reader :target, :diff
    
    Destination = Struct.new :path, :full_path do
      def content
        @content ||= StringIO.new
      end
    end
    
    def begin_file(*name)
      @current_destination << Destination.new(Pathname(File.join(name)), target + File.join(name))
    end
    
    def newline
      $/
    end
    
    alias_method :nl, :newline
    
    def append(*s)
      unless @current_destination.empty?
        @current_destination.last.content.print(*s)
      end
    end
    
    def finish_file
      destination = @current_destination.pop
      print "Generating #{destination.path} ... "
      full_path = destination.full_path
      content = destination.content.string
      if diff and full_path.exist?
        diff = Diffy::Diff.new(full_path.read, content)
        if diff.to_s.empty?
          puts P.cyan("skip")
        else
          puts P.bold.yellow("update")
        end
      else
        puts P.bold.green("create")
      end
      full_path.parent.mkpath
      full_path.write(content)
    end
    
  end
  
end
