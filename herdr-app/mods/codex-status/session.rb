require "json"
require "open3"

module CodexSession
  def self.label(terminal, home = ENV.fetch("CODEX_HOME", File.expand_path("~/.codex")))
    cwd = terminal.dig("foreground", "cwd") || terminal["cwd"]
    return nil unless cwd

    database = File.join(home, "state_5.sqlite")
    return nil unless File.file?(database)

    query = "SELECT id, model, reasoning_effort FROM threads WHERE archived = 0 AND cwd = '#{cwd.gsub("'", "''")}'"
    output, status = Open3.capture2("sqlite3", "-readonly", "-json", database, query)
    return nil unless status.success?

    sessions = JSON.parse(output.empty? ? "[]" : output).select do |session|
      path = File.join(home, "thread-writer-locks", "#{session.fetch('id')}.lock")
      next false unless File.file?(path)

      File.open(path) do |file|
        locked = file.flock(File::LOCK_EX | File::LOCK_NB)
        file.flock(File::LOCK_UN) if locked
        !locked
      end
    rescue Errno::ENOENT
      false
    end
    return nil unless sessions.length == 1

    session = sessions.first
    return nil unless session["model"] && session["reasoning_effort"]

    "#{session['model']} #{session['reasoning_effort']}"
  end
end

if $PROGRAM_NAME == __FILE__
  begin
    puts JSON.generate(label: CodexSession.label(JSON.parse(ARGV.fetch(0))))
  rescue StandardError
    warn "Codex session unavailable"
    exit 1
  end
end
