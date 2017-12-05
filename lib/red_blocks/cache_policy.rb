module RedBlocks
  module CachePolicy
    def self.none
      0
    end

    def self.daily
      # 15.minutes is padding for daily update.
      # This will avoid to expire the cache before
      # the update has completed.
      24.hours + 15.minutes
    end

    def self.hourly
      # 3.minutes is padding for hourly update.
      # This will avoid to expire the cache before
      # the update has completed.
      1.hour + 3.minutes
    end
  end
end
