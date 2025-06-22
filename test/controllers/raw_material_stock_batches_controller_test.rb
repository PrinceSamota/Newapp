require "test_helper"

class RawMaterialStockBatchesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get raw_material_stock_batches_new_url
    assert_response :success
  end

  test "should get create" do
    get raw_material_stock_batches_create_url
    assert_response :success
  end

  test "should get index" do
    get raw_material_stock_batches_index_url
    assert_response :success
  end
end
