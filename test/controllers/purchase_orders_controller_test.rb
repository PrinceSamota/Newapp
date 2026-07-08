require "test_helper"

class PurchaseOrdersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @po = PurchaseOrder.create!(
      po_number: "PO-X001",
      po_date: Date.today,
      supplier_name: "Test Supplier",
      sku_id: "SKU-A",
      item_name: "Item A",
      quantity: 1000,
      purchase_price: 12.50,
      delivered_quantity: 0,
      status: "Open"
    )
  end

  test "should redirect to login if not authenticated" do
    get purchase_orders_path
    assert_redirected_to new_user_session_path
  end

  test "should get index when authenticated" do
    sign_in @user
    get purchase_orders_path
    assert_response :success
  end

  test "should create purchase order" do
    sign_in @user
    assert_difference("PurchaseOrder.count", 1) do
      post purchase_orders_path, params: {
        purchase_order: {
          po_number: "PO-X002",
          po_date: Date.today,
          supplier_name: "Vendor Y",
          sku_id: "SKU-Y",
          item_name: "Item Y",
          quantity: 500,
          purchase_price: 25.0
        }
      }
    end
    assert_redirected_to purchase_orders_path
  end

  test "should partially convert purchase order to rmi" do
    sign_in @user
    item = item_masters(:one)
    initial_stock = item.opening_stock

    assert_difference("RawMaterialInward.count", 1) do
      post convert_to_rmi_purchase_order_path(@po), params: {
        quantity_to_convert: 300,
        receiving_date: Date.today.to_s
      }
    end

    @po.reload
    assert_equal 300, @po.delivered_quantity
    assert_equal 700, @po.remaining_quantity
    assert_equal "Open", @po.status

    rmi = RawMaterialInward.last
    assert_equal @po.id, rmi.purchase_order_id
    assert_equal 300, rmi.receiving_quantity
    assert_equal "Test Supplier", rmi.supplier_name

    # Verify stock updated
    item.reload
    assert_equal initial_stock + 300, item.opening_stock

    # Verify PaperTrail version is created and linked
    version = item.versions.last
    assert_not_nil version
    assert_equal "RawMaterialInward", version.source_type
    assert_equal rmi.id, version.source_id
    assert_equal "Converted from PO: #{@po.po_number}", version.reason
  end

  test "should fully convert purchase order to rmi and close it" do
    sign_in @user
    item = item_masters(:one)
    initial_stock = item.opening_stock

    # First partial conversion
    post convert_to_rmi_purchase_order_path(@po), params: {
      quantity_to_convert: 700,
      receiving_date: Date.today.to_s
    }
    @po.reload
    assert_equal "Open", @po.status

    # Final conversion to close PO
    assert_difference("RawMaterialInward.count", 1) do
      post convert_to_rmi_purchase_order_path(@po), params: {
        quantity_to_convert: 300,
        receiving_date: Date.today.to_s
      }
    end

    @po.reload
    assert_equal 1000, @po.delivered_quantity
    assert_equal 0, @po.remaining_quantity
    assert_equal "Closed", @po.status

    # Verify stock updated completely (700 + 300 = 1000 added)
    item.reload
    assert_equal initial_stock + 1000, item.opening_stock
  end

  test "should fail conversion if quantity exceeds remaining" do
    sign_in @user
    post convert_to_rmi_purchase_order_path(@po), params: {
      quantity_to_convert: 1200,
      receiving_date: Date.today.to_s
    }
    assert_redirected_to edit_purchase_order_path(@po)
    
    @po.reload
    assert_equal 0, @po.delivered_quantity
    assert_equal "Open", @po.status
  end
end
