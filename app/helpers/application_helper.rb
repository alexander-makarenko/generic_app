module ApplicationHelper

  def sortable(column, title = nil)
    title ||= column.titleize

    if column == sort_column
      css_class = "current #{sort_direction}"
      direction = sort_direction == 'asc' ? 'desc' : 'asc'
    end

    link_to title, { sort: column, direction: direction }, { class: css_class }    
  end
end