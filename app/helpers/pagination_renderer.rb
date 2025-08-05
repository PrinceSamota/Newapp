class PaginationRenderer < WillPaginate::ActionView::LinkRenderer
    def page_number(page)
      if page == current_page
        tag(:span, page, class: "px-3 py-1 text-sm bg-blue-500 text-white border border-blue-500 rounded")
      else
        link(page, page, class: "px-3 py-1 text-sm bg-white border border-gray-300 rounded hover:bg-gray-100")
      end
    end
  
    def previous_or_next_page(page, text, classname, rel)
      if page
        link(text, page, class: "px-3 py-1 text-sm bg-white border border-gray-300 rounded hover:bg-gray-100")
      else
        tag(:span, text, class: "px-3 py-1 text-sm bg-gray-200 text-gray-500 border border-gray-300 rounded cursor-not-allowed")
      end
    end
  end
  