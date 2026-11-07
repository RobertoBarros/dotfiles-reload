require "minitest/autorun"
require "tmpdir"
require "fileutils"
require_relative "session"

class CodexSessionTest < Minitest::Test
  def setup
    @home = Dir.mktmpdir
    @locks = []
    FileUtils.mkdir_p(File.join(@home, "thread-writer-locks"))
    sql = "CREATE TABLE threads (id TEXT, cwd TEXT, model TEXT, reasoning_effort TEXT, archived INTEGER);"
    Open3.capture2("sqlite3", File.join(@home, "state_5.sqlite"), sql)
  end

  def teardown
    @locks.each(&:close)
    FileUtils.remove_entry(@home)
  end

  def session(id, cwd, active: true)
    sql = "INSERT INTO threads VALUES ('#{id}', '#{cwd.gsub("'", "''")}', 'gpt-6.1-sol', 'high', 0);"
    Open3.capture2("sqlite3", File.join(@home, "state_5.sqlite"), sql)
    file = File.open(File.join(@home, "thread-writer-locks", "#{id}.lock"), "w")
    file.flock(File::LOCK_EX) if active
    @locks << file
  end

  def test_model_and_reasoning_without_any_terminal_screen
    session("current", "/repo")
    session("old", "/repo", active: false)
    session("other", "/other")
    assert_equal "gpt-6.1-sol high", CodexSession.label({ "cwd" => "/repo" }, @home)
  end

  def test_uses_foreground_directory_after_shell_changes_directory
    session("current", "/repo's folder")
    terminal = { "cwd" => "/old", "foreground" => { "cwd" => "/repo's folder" } }
    assert_equal "gpt-6.1-sol high", CodexSession.label(terminal, @home)
  end

  def test_does_not_guess_between_active_sessions_in_the_same_directory
    session("first", "/repo")
    session("second", "/repo")
    assert_nil CodexSession.label({ "cwd" => "/repo" }, @home)
  end

  def test_does_not_use_a_closed_session
    session("old", "/repo", active: false)
    assert_nil CodexSession.label({ "cwd" => "/repo" }, @home)
  end
end
