require "test_helper"

class OnboardingControllerTest < ActionDispatch::IntegrationTest
  test "should get upload" do
    get onboarding_upload_url
    assert_response :success
  end
end
