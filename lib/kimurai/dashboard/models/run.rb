module Kimurai::Dashboard
  class Run < Sequel::Model(DB)
  many_to_one :session
  many_to_one :spider

  plugin :json_serializer
  plugin :serialization
  plugin :serialization_modification_detection
  serialize_attributes :json, :visits, :items, :server, :events

  # scopes
  dataset_module do
    def spider_id(id)
      filter(spider_id: id)
    end

    def session_id(id)
      filter(session_id: id)
    end
  end

  def latest?
    Run.where(spider_name: spider_name).last == self
  end

  def difference_between_previous_run
    previous_run = Run.where(spider_name: spider_name).reverse_order(:id).first(Sequel[:id] < id)
    return unless previous_run

    {
      visits: {
        requests: {
          current: visits["requests"],
          previous: previous_run.visits["requests"],
          difference: calculate_difference(visits["requests"], previous_run.visits["requests"])
        },
        responses: {
          current: visits["responses"],
          previous: previous_run.visits["responses"],
          difference: calculate_difference(visits["responses"], previous_run.visits["responses"])
        }
      },
      items: {
        sent: {
          current: items["sent"],
          previous: previous_run.items["sent"],
          difference: calculate_difference(items["sent"], previous_run.items["sent"])
        },
        processed: {
          current: items["processed"],
          previous: previous_run.items["processed"],
          difference: calculate_difference(items["processed"], previous_run.items["processed"])
        }
      },
      previous_run_id: previous_run.id
    }
  end

  private

  def calculate_difference(current, previous)
    return if current == 0 || previous == 0
    (((current - previous).to_r / previous) * 100).to_f.round(1)
  end
end
end
