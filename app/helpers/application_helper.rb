module ApplicationHelper
  def page_title(title = '')
    base_title = '未定'
    title.present? ? "#{title} | #{base_title}" : base_title
  end
end
