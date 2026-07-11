class ReportsController < ApplicationController
  def index
    order_ids = params[:order_ids].to_s.split(",")
    @orders = OrderEntry.where(id: order_ids)
    @selected_order_numbers = @orders.pluck(:order_no)

    sku_totals = @orders.group(:sku_number).sum(:qty)

    final_hash = {}

    sku_totals.each do |sku_id, total_qty|
      expand_bom(sku_id, total_qty, final_hash)
    end

    @report_data = final_hash.values

    respond_to do |format|
      format.html
      format.xlsx do
        response.headers['Content-Disposition'] =
          'attachment; filename="report.xlsx"'
      end
    end
  end

  private

  # 🔥 CLEAN RECURSIVE METHOD (No duplicates)
  def expand_bom(sku_id, qty_needed, accumulator, visited = Set.new)
    return if visited.include?(sku_id)
    visited.add(sku_id)

    item = ItemMaster.find_by(sku_id: sku_id)
    return unless item

    stock = item.opening_stock || 0

    # ✅ Always merge into ONE accumulator
    if accumulator[sku_id]
      accumulator[sku_id][:quantity] += qty_needed
      accumulator[sku_id][:actual_required_qty] += qty_needed
      accumulator[sku_id][:requirement] =
        accumulator[sku_id][:stock] - accumulator[sku_id][:quantity]
    else
      po_qty = PurchaseOrderItem.where(sku_id: sku_id).to_a.sum(&:remaining_quantity)

      accumulator[sku_id] = {
        sku: sku_id,
        item_name: item.item_name,
        category: item.category&.name,
        quantity: qty_needed,
        stock: stock,
        requirement: stock - qty_needed,
        actual_required_qty: qty_needed,
        po_quantity: po_qty
      }
    end

    bom = BillOfMaterial
            .joins(:finished_good)
            .find_by(finished_goods: { sku_id: sku_id })

    return unless bom

    bom.bom_raw_material_items.each do |rm|
      next if rm.quantity.blank?

      rm_item = rm.item_master
      next unless rm_item

      rm_sku = rm_item.sku_id

      # ✅ IMPORTANT: always multiply by parent order qty
      child_required_qty = qty_needed * rm.quantity

      expand_bom(
        rm_sku,
        child_required_qty,
        accumulator,
        visited.dup
      )
    end
  end
end