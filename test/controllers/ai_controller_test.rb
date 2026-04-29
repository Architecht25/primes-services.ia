require "test_helper"

class AiControllerTest < ActionDispatch::IntegrationTest
  # AI controller routes require a valid AiConversation record (external service dependency).
  # These are covered by service-level tests in test/services/.
end
