class HomeController < ApplicationController
  def index
    # パラメータ（無ければデフォルト）
    @cohort   = params.fetch(:cohort, "all")
    @category = params.fetch(:category, "tech")
    @category = "tech" unless Theme::CATEGORY_KEYS.include?(@category)

    # セレクト用（存在する期だけ出す）
    @cohort_options = User.cohort_options

    # 集計（共通基盤を呼ぶ）
    @availability_counts = Availability::AggregateCounts.call(
      cohort: @cohort,
      category: @category
    )
  end
end
