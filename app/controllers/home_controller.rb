class HomeController < ApplicationController
  def index
    # パラメータ（無ければデフォルト）
    @cohort   = params.fetch(:cohort, "all")
    @category = params.fetch(:category, "tech")
    @category = "tech" unless %w[tech community].include?(@category)

    # セレクト用（存在する期だけ出す）
    @cohort_options = User.distinct.order(:cohort).pluck(:cohort).compact

    # 集計（共通基盤を呼ぶ）
    @availability_counts = Availability::AggregateCounts.call(
      cohort: @cohort,
      category: @category
    )
  end
end
