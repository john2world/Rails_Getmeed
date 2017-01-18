class GenerateAdminMetricsWorker
  include Sidekiq::Worker
  include AdminsManager

  sidekiq_options retry: true, :queue => :low

  def perform(metric_type)
    case metric_type
      when "key_metrics"
        key_metrics = get_dashboard_keymetrics
        $redis.set("admin_dashboard_key_metrics", key_metrics)
        $redis.set("admin_dashboard_key_metrics_timestamp", Time.now())
        # schedule a automatic computation at 2:00 AM in the morning the next day
        GenerateAdminMetricsWorker.perform_at(Time.parse("2:00 AM")+1.day, metric_type)
    end
  end
end