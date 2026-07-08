require "test_helper"

class RawMaterialInwardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  test "should get index when authenticated" do
    sign_in @user
    get raw_material_inwards_path
    assert_response :success
  end
end
