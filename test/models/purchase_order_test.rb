require "test_helper"

class PurchaseOrderTest < ActiveSupport::TestCase
  test "valid purchase order saves successfully" do
    po = PurchaseOrder.new(
      po_number: "PO-1001",
      po_date: Date.today,
      supplier_name: "Acme Corp",
      sku_id: "LED-001",
      item_name: "LED Bulb 9W",
      quantity: 1000,
      purchase_price: 15.5
    )
    assert po.save
    assert_equal 0, po.delivered_quantity
    assert_equal "Open", po.status
    assert_equal 1000, po.remaining_quantity
  end

  test "invalid purchase order fails validation" do
    po = PurchaseOrder.new
    assert_not po.save
    assert_includes po.errors[:po_number], "can't be blank"
    assert_includes po.errors[:quantity], "can't be blank"
  end

  test "quantity must be greater than zero" do
    po = PurchaseOrder.new(
      po_number: "PO-1001",
      po_date: Date.today,
      supplier_name: "Acme Corp",
      sku_id: "LED-001",
      item_name: "LED Bulb 9W",
      quantity: 0,
      purchase_price: 15.5
    )
    assert_not po.save
    assert_includes po.errors[:quantity], "must be greater than 0"
  end

  test "delivered_quantity cannot exceed quantity" do
    po = PurchaseOrder.new(
      po_number: "PO-1001",
      po_date: Date.today,
      supplier_name: "Acme Corp",
      sku_id: "LED-001",
      item_name: "LED Bulb 9W",
      quantity: 1000,
      purchase_price: 15.5,
      delivered_quantity: 1100
    )
    assert_not po.save
    assert_includes po.errors[:delivered_quantity], "cannot exceed the ordered quantity"
  end
end
