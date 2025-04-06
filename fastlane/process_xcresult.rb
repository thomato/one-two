#!/usr/bin/env ruby

require 'json'
require 'fileutils'

# This script processes xcresult files without using trainer
# It's intended as a fallback if the trainer monkey patch doesn't work

class XCResultProcessor
  def self.process(xcresult_path, output_dir)
    puts "Processing xcresult at: #{xcresult_path}"
    
    # Create output directory if it doesn't exist
    FileUtils.mkdir_p(output_dir) unless Dir.exist?(output_dir)
    
    # Get summary data using xcresulttool with correct syntax: get object --legacy
    json_data = `xcrun xcresulttool get object --legacy --format json --path "#{xcresult_path}"`
    if $?.success?
      # Save raw JSON for debugging
      File.write(File.join(output_dir, "xcresult_summary.json"), json_data)
      
      # Process the JSON data to extract test results
      if !json_data.empty?
        puts "Successfully extracted xcresult data"
        puts "Test results saved to: #{output_dir}"
      else
        puts "Error: Empty JSON data returned from xcresulttool"
      end
    else
      puts "Error running xcresulttool. Command failed."
    end
  end
end

# If run directly (not required)
if __FILE__ == $0
  if ARGV.length < 2
    puts "Usage: #{$0} <xcresult_path> <output_dir>"
    exit 1
  end
  
  xcresult_path = ARGV[0]
  output_dir = ARGV[1]
  
  XCResultProcessor.process(xcresult_path, output_dir)
end