class ReportsController < ApplicationController
  def index
    order_ids = params[:order_ids].to_s.split(",")
    @orders = OrderEntry.where(id: order_ids)
    @selected_order_numbers = @orders.pluck(:order_no)

    # Step 1: Aggregate total quantity per SKU across all orders
    sku_totals = @orders.group(:sku_number).sum(:qty)

    sku_hash = {}

    # Step 2: Expand BOM for each SKU once, using total quantity
    sku_totals.each do |sku_id, total_qty|
      bom_items = expand_bom(sku_id, total_qty)
      
      # Step 3: Merge results into cumulative hash
      bom_items.each do |s, row|
        if sku_hash[s]
          sku_hash[s][:quantity] += row[:quantity]
          sku_hash[s][:requirement] = sku_hash[s][:stock] - sku_hash[s][:quantity]
          sku_hash[s][:actual_required_qty] += row[:actual_required_qty]
        else
          sku_hash[s] = row
        end
      end
    end

    @report_data = sku_hash.values

    respond_to do |format|
      format.html
      format.xlsx do
        response.headers['Content-Disposition'] = 'attachment; filename="report.xlsx"'
      end
    end
  end

  private

  # Recursive BOM expansion
  def expand_bom(sku_id, qty_needed, visited = Set.new)
    return {} if visited.include?(sku_id)
    visited.add(sku_id)

    item = ItemMaster.find_by(sku_id: sku_id)
    return {} unless item

    stock = item.opening_stock || 0
    to_produce_qty = [qty_needed - stock, 0].max

    result = {}
    # Default entry: finished good / intermediate
    result[sku_id] = {
      sku: sku_id,
      item_name: item.item_name,
      category: item.category&.name,
      quantity: qty_needed,
      stock: stock,
      requirement: stock - qty_needed,
      actual_required_qty: 0  # Only leaf raw materials will have actual required qty
    }

    bom = BillOfMaterial.joins(:finished_good).find_by(finished_goods: { sku_id: sku_id })
    return result unless bom

    bom.bom_raw_material_items.each do |rm|
      next if rm.quantity.nil?

      rm_item = rm.item_master
      rm_sku = rm_item.sku_id
      rm_name = rm_item.item_name
      rm_stock = rm_item.opening_stock || 0

      total_required_qty = to_produce_qty * rm.quantity

      if BillOfMaterial.joins(:finished_good).exists?(finished_goods: { sku_id: rm_sku })
        # Multi-level BOM: recurse
        child_results = expand_bom(rm_sku, total_required_qty, visited.dup)
        child_results.each do |child_sku, child_data|
          if result[child_sku]
            result[child_sku][:quantity] += child_data[:quantity]
            result[child_sku][:requirement] = result[child_sku][:stock] - result[child_sku][:quantity]
            result[child_sku][:actual_required_qty] += child_data[:actual_required_qty]
          else
            result[child_sku] = child_data
          end
        end
      else
        # Leaf raw material: actual required quantity
        if result[rm_sku]
          result[rm_sku][:quantity] += total_required_qty
          result[rm_sku][:requirement] = result[rm_sku][:stock] - result[rm_sku][:quantity]
          result[rm_sku][:actual_required_qty] += total_required_qty
        else
          result[rm_sku] = {
            sku: rm_sku,
            item_name: rm_name,
            category: rm_item.category&.name,
            quantity: total_required_qty,
            stock: rm_stock,
            requirement: rm_stock - total_required_qty,
            actual_required_qty: total_required_qty
          }
        end
      end
    end

    result
  end
end