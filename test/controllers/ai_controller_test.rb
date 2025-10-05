require "test_helper"

class AiControllerTest < ActionDispatch::IntegrationTest
  test "should get chat" do
    get ai_chat_url
    assert_response :success
  end

  test "should get history" do
    get ai_history_url
    assert_response :success
  end

  test "should get reset" do
    get ai_reset_url
    assert_response :success
  end

  test "should get stats" do
    get ai_stats_url
    assert_response :success
  end
end
