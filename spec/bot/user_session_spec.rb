# frozen_string_literal: true

require "our_web_gem/bot/user_session"

RSpec.describe OurWebGem::Bot::UserSession do
  let(:session) { described_class.new }

  it "starts with idle state" do
    expect(session.state).to eq(:idle)
  end

  it "can switch to waiting for markdown state" do
    session.wait_for_markdown

    expect(session).to be_waiting_for_markdown
  end

  it "can reset state" do
    session.wait_for_markdown
    session.reset_state

    expect(session.state).to eq(:idle)
  end

  it "saves last conversion" do
    session.save_conversion("# Hello", "<h1>Hello</h1>")

    expect(session.last_markdown).to eq("# Hello")
    expect(session.last_html).to eq("<h1>Hello</h1>")
  end

  it "knows when history exists" do
    expect(session).not_to be_history

    session.save_conversion("# Hello", "<h1>Hello</h1>")

    expect(session).to be_history
  end

  it "can clear history" do
    session.save_conversion("# Hello", "<h1>Hello</h1>")
    session.clear_history

    expect(session).not_to be_history
    expect(session.last_markdown).to be_nil
    expect(session.last_html).to be_nil
  end
end