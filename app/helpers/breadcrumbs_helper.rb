module BreadcrumbsHelper
  # パンくず要素を1つ作る（url は省略OK。省略すると「現在地」扱い）
  def bc(label, url = nil)
    { label: label, url: url }
  end

  # items が空なら何も表示しない
  def render_breadcrumbs(items)
    return if items.blank?

    render "shared/breadcrumb", items: items
  end
end