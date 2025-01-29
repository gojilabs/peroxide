# frozen_string_literal: true

require 'peroxide'

class ProjectSanitizer < Peroxide::Sanitizer
  phases = %i[strategy design development maintenance].freeze

  action :index do
    request do
      integer :page, required: true, range: (1..)
      integer :per_page, required: true, range: (1..40)
    end

    response 200 do
      array :projects, length: (0..40), required: true do
        object do
          string :name, required: true, length: 5..120
          string :description, length: 0..255
          string :url, length: 0..255
          enum :phase, phases, required: true
          float :projected_cost, required: true, range: (0..)
          integer :id, required: true, range: (1..)
          datetime :created_at, required: true
          datetime :deleted_at
          datetime :completed_at
          datetime :cancelled_at
        end
      end

      integer :project_count, required: true, range: (0..40)
      integer :total_count, required: true, range: (0..)
      integer :page, required: true, range: (1..)
      integer :per_page, required: true, range: (1..40)
    end

    response 204 do
      no_content
    end

    response 404 do
      object :error, required: true do
        string :message, required: true, length: 1..255
      end
    end
  end

  action :create do
    request do
      object :project, required: true do
        string :name, required: true, length: 5..120
        string :description, length: 0..255
        string :url, length: 0..255
        enum :phase, phases, required: true
        float :projected_cost, required: true, range: (0..)
        integer :id, required: true, range: (1..)
      end
    end

    response 201 do
      object :project, required: true do
        integer :id, required: true, range: (1..)
        string :name, required: true, length: 5..120
        string :description, length: 0..255
        string :url, length: 0..255
        enum :phase, phases, required: true
        float :projected_cost, required: true, range: (0..)
        datetime :created_at, required: true
        datetime :deleted_at
        datetime :completed_at
        datetime :cancelled_at
      end
    end

    response 400 do
      object :error, required: true do
        string :message, required: true, length: 1..255
      end
    end
  end
end
