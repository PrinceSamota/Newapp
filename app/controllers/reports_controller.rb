class ReportsController < ApplicationController
  def index
    order_ids = params[:order_ids].to_s.split(",")
    @orders = OrderEntry.where(id: order_ids)
    @selected_order_numbers = @orders.pluck(:order_no)

    sku_hash = {}

    @orders.each do |order|
      bom_items = expand_bom(order.sku_number, order.qty)

      bom_items.each do |sku, row|
        if sku_hash[sku]
          sku_hash[sku][:quantity] += row[:quantity]
          sku_hash[sku][:requirement] = sku_hash[sku][:stock] - sku_hash[sku][:quantity]
        else
          sku_hash[sku] = row
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

  def expand_bom(sku_id, qty_needed, visited = Set.new)
    return {} if visited.include?(sku_id)
    visited.add(sku_id)
  
    item = ItemMaster.find_by(sku_id: sku_id)
    return {} unless item
  
    stock = item.opening_stock || 0
  
    # Determine how many need to be produced (if stock already satisfies some)
    to_produce_qty = [qty_needed - stock, 0].max
  
    result = {}
    result[sku_id] = {
      sku: sku_id,
      item_name: item.item_name,
      quantity: qty_needed,
      stock: stock,
      requirement: stock - qty_needed
    }
  
    bom = BillOfMaterial.joins(:finished_good).find_by(finished_goods: { sku_id: sku_id })
    return result unless bom
  
    bom.bom_raw_material_items.each do |rm|
      next if rm.quantity.nil?
  
      rm_item = rm.item_master
      rm_sku = rm_item.sku_id
      rm_name = rm_item.item_name
      rm_stock = rm_item.opening_stock || 0
  
      # Only compute raw material requirement based on actual production needed
      total_required_qty = to_produce_qty * rm.quantity
  
      if BillOfMaterial.joins(:finished_good).exists?(finished_goods: { sku_id: rm_sku })
        child_results = expand_bom(rm_sku, total_required_qty, visited.dup)
  
        child_results.each do |child_sku, child_data|
          if result[child_sku]
            result[child_sku][:quantity] += child_data[:quantity]
            result[child_sku][:requirement] = result[child_sku][:stock] - result[child_sku][:quantity]
          else
            result[child_sku] = child_data
          end
        end
      else
        if result[rm_sku]
          result[rm_sku][:quantity] += total_required_qty
          result[rm_sku][:requirement] = result[rm_sku][:stock] - result[rm_sku][:quantity]
        else
          result[rm_sku] = {
            sku: rm_sku,
            item_name: rm_name,
            quantity: total_required_qty,
            stock: rm_stock,
            requirement: rm_stock - total_required_qty
          }
        end
      end
    end
  
    result
  end
end
