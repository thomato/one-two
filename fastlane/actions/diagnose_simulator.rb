module Fastlane
  module Actions
    class DiagnoseSimulatorAction < Action
      def self.run(params)
        UI.message("Starting simulator diagnostics...")
        
        # Get system info
        UI.message("System info:")
        sh("sw_vers")
        sh("xcodebuild -version")
        
        # Check available space
        UI.message("Available disk space:")
        sh("df -h /")
        
        # Check simulator runtimes
        UI.message("Available simulator runtimes:")
        sh("xcrun simctl list runtimes")
        
        # Check available devices
        UI.message("Available simulator devices:")
        sh("xcrun simctl list devices")
        
        # Check booted simulators
        UI.message("Currently booted simulators:")
        sh("xcrun simctl list devices | grep 'Booted'")
        
        # Check process usage
        UI.message("Process usage:")
        sh("ps aux | grep -i simul")
        
        # Memory and CPU usage
        UI.message("Memory and CPU usage:")
        sh("top -l 1 | head -n 15")
        
        # Check system load
        UI.message("System load:")
        sh("sysctl vm.loadavg")
        
        # Check launchd for simulator services
        UI.message("Simulator launchd services:")
        sh("launchctl list | grep -i simulator")
        
        # Create diagnostics zip
        UI.message("Creating complete simulator diagnostics...")
        sh("xcrun simctl diagnose --all --output #{params[:output_path]}")
        
        UI.success("Simulator diagnostics completed!")
      end

      def self.description
        "Collects detailed diagnostics about the simulator environment"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :output_path,
                                       description: "Path to save diagnostics zip",
                                       default_value: "./simulator_diagnostics.zip",
                                       optional: true,
                                       type: String)
        ]
      end

      def self.authors
        ["Your Name"]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end
    end
  end
end
