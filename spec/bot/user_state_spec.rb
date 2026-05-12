# frozen_string_literal: true

require "our_web_gem/bot/user_state"

RSpec.describe OurWebGem::Bot::UserState do
  let(:state) { described_class.new }
  let(:chat_id) { 123 }

  it "returns idle state by default" do
    expect(state.get(chat_id)).to eq(:idle)
  end

  it "sets user state" do
    state.set(chat_id, :waiting_for_markdown)

    expect(state.get(chat_id)).to eq(:waiting_for_markdown)
  end

  it "resets user state" do
    state.set(chat_id, :waiting_for_markdown)
    state.reset(chat_id)

    expect(state.get(chat_id)).to eq(:idle)
  end

  it "stores states for different users separately" do
    first_chat_id = 123
    second_chat_id = 456

    state.set(first_chat_id, :waiting_for_markdown)

    expect(state.get(first_chat_id)).to eq(:waiting_for_markdown)
    expect(state.get(second_chat_id)).to eq(:idle)
  end
end