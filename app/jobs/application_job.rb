class ApplicationJob < ActiveJob::Base
  queue_as :default

  # デッドロック発生時に最大3回リトライ
  retry_on ActiveRecord::Deadlocked, attempts: 3

  # レコードが削除済みの場合はジョブを破棄
  discard_on ActiveJob::DeserializationError
end
