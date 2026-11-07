require "json"
require "open3"
require "timeout"

begin
  Open3.popen2("codex", "app-server", "--stdio", err: File::NULL) do |input, output, process|
    begin
      result = Timeout.timeout(15) do
        request = ->(message) { input.puts(JSON.generate(message)); input.flush }
        response = lambda do |id|
          loop do
            line = output.gets
            raise "Codex connection closed" unless line
            message = JSON.parse(line)
            next unless message["id"] == id
            raise "Codex request failed" if message["error"]
            break message.fetch("result")
          end
        end

        request.call(id: 1, method: "initialize", params: { clientInfo: { name: "herdr_usage", version: "1.0.0" } })
        response.call(1)
        request.call(method: "initialized")
        request.call(id: 2, method: "account/rateLimits/read")
        data = response.call(2)
        limits = data.dig("rateLimitsByLimitId", "codex") || data.fetch("rateLimits")
        limits.slice("primary", "secondary")
      end
      puts JSON.generate(result)
    ensure
      input.close unless input.closed?
      unless process.join(1)
        Process.kill("TERM", process.pid) rescue Errno::ESRCH
      end
    end
  end
rescue StandardError
  warn "Codex rate limits unavailable"
  exit 1
end
