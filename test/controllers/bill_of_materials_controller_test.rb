require "test_helper"

class BillOfMaterialsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get bill_of_materials_new_url
    assert_response :success
  end

  test "should get create" do
    get bill_of_materials_create_url
    assert_response :success
  end

  test "should get index" do
    get bill_of_materials_index_url
    assert_response :success
  end
end
