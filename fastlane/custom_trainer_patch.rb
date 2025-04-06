module Trainer
  class TestParser
    def execute_cmd(cmd)
      # Add --legacy flag to xcresulttool commands with the correct object subcommand
      if cmd.include?('xcresulttool get')
        cmd = cmd.sub('xcresulttool get', 'xcresulttool get object --legacy')
      end
      
      puts("Executing #{cmd}")
      result = `#{cmd}`
      return result
    end
  end
end