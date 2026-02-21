namespace :themes do
  desc "全テーマの開催しやすさスコアを再計算してDBキャッシュを更新する"
  task recalculate_hosting_ease: :environment do
    themes = Theme.all
    puts "#{themes.count}件のテーマのスコアを再計算します..."

    themes.find_each do |theme|
      theme.recalculate_hosting_ease_score!
      print "."
    end

    puts "\n完了しました。"
  end
end
