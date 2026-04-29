require "test_helper"
require "minitest/mock"

class AiChatbotServiceTest < ActiveSupport::TestCase
  setup do
    @service = AiChatbotService.new(user_type: "particulier", user_region: "wallonie")
  end

  # --- Instantiation ---

  test "creates a new conversation on initialize" do
    assert_not_nil @service.conversation
    assert_equal "wallonie", @service.conversation.user_region
    assert_equal "particulier", @service.conversation.user_type
  end

  test "reuses existing conversation by session_id" do
    session_id = @service.conversation.session_id
    service2 = AiChatbotService.new(session_id: session_id)
    assert_equal @service.conversation.id, service2.conversation.id
  end

  # --- process_message guards ---

  test "returns error response for blank message" do
    result = @service.process_message("")
    assert_equal false, result[:success]
    assert_match(/vide/i, result[:error])
  end

  test "returns error response for nil message" do
    result = @service.process_message(nil)
    assert_equal false, result[:success]
  end

  # --- process_message with mocked API ---

  test "returns success response when Anthropic API replies" do
    mock_response = mock_anthropic_response("Voici les primes disponibles en Wallonie.")

    HTTParty.stub(:post, mock_response) do
      result = @service.process_message("Quelles primes existent en Wallonie ?")
      assert_equal true, result[:success]
      assert_includes result[:data][:content], "Wallonie"
    end
  end

  test "adds user message to conversation history" do
    mock_response = mock_anthropic_response("Réponse test.")

    HTTParty.stub(:post, mock_response) do
      @service.process_message("Bonjour")
    end

    history = @service.conversation_history
    user_msgs = history.select { |m| (m[:role] || m["role"]) == "user" }
    assert user_msgs.any? { |m| (m[:content] || m["content"]).include?("Bonjour") }
  end

  test "adds assistant message to conversation history" do
    mock_response = mock_anthropic_response("Réponse assistant.")

    HTTParty.stub(:post, mock_response) do
      @service.process_message("Test")
    end

    history = @service.conversation_history
    assistant_msgs = history.select { |m| (m[:role] || m["role"]) == "assistant" }
    assert assistant_msgs.any?
  end

  # --- conversation_stats ---

  test "conversation_stats returns expected keys" do
    stats = @service.conversation_stats
    assert_includes stats.keys, :message_count
    assert_includes stats.keys, :session_id
    assert_includes stats.keys, :user_profile
  end

  # --- reset_conversation! ---

  test "reset_conversation! clears message history" do
    mock_response = mock_anthropic_response("Réponse.")
    HTTParty.stub(:post, mock_response) do
      @service.process_message("Premier message")
    end

    @service.reset_conversation!
    assert_equal [], @service.conversation_history
  end

  private

  # Build a minimal fake HTTParty response mimicking Anthropic's JSON shape
  def mock_anthropic_response(text)
    body = { "content" => [{ "text" => text, "type" => "text" }] }.to_json
    response = Struct.new(:code, :body) do
      def dig(*keys)
        JSON.parse(body).dig(*keys)
      end
    end.new(200, body)
    response
  end
end
