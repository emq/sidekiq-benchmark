require 'minitest/pride'

require 'bundler/setup'
require 'rack/test'

require 'sidekiq'
require 'sidekiq/util'
require 'sidekiq-benchmark'

REDIS = Sidekiq::RedisConnection.create url: "redis://localhost/15", namespace: "testy"

Bundler.require

module Sidekiq
  module Benchmark
    module Test

      class WorkerMock
        include Sidekiq::Worker
        include Sidekiq::Benchmark::Worker

        attr_reader :bm_obj, :metric_names

        def self.id
          @id = @id.to_i + 1
        end

        def initialize
          @bm_obj = benchmark(self.class.id) do |bm|
            bm.test_metric do
              2.times do |i|
                bm.send("nested_test_metric_#{i}") do
                  100500.times do |i|
                  end
                end
              end
            end
          end

          @metric_names = [:test_metric, :nested_test_metric_1, :job_time]
        end
      end

      def self.flush_db
        Sidekiq.redis = REDIS
        Sidekiq.redis do |conn|
          conn.flushdb
        end
      end

    end
  end
end