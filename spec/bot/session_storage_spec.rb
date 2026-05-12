# frozen_string_literal: true

require "our_web_gem/bot/session_storage"

RSpec.describe OurWebGem::Bot::SessionStorage do
  let(:storage) { described_class.new }

  it "returns session for chat id" do
    session = storage.session_for(123)

    expect(session).to be_a(OurWebGem::Bot::UserSession)
  end

  it "returns the same session for the same chat id" do
    first_session = storage.session_for(123)
    second_session = storage.session_for(123)

    expect(first_session).to equal(second_session)
  end

  it "returns different sessions for different chat ids" do
    first_session = storage.session_for(123)
    second_session = storage.session_for(456)

    expect(first_session).not_to equal(second_session)
  end
end