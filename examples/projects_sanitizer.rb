# frozen_string_literal: true

require 'peroxide'

class ProjectSanitizer < Peroxide::Sanitizer
  index do
    request do
      integer :page, required: true, range: (1..)
      integer :per_page, required: true, range: (1..ENV['PER_PAGE'].to_i)
    end

    response :ok do
      array :projects, length: (0..ENV['PER_PAGE'].to_i), required: true do
        string :name, required: true, length: 5..120
        string :description, length: 0..255
        string :url, length: 0..255
      end

      integer :project_count, required: true, range: (0..ENV['PER_PAGE'].to_i)
      integer :total_count, required: true, range: (0..)
      integer :page, required: true, range: (1..)
      integer :per_page, required: true, range: (1..ENV['PER_PAGE'].to_i)
    end

    response :not_found do
      object :error, required: true do
        string :message, required: true, length: 1..255
      end
    end
  end

  create do
    request do
      object :project, required: true do
        string :name, required: true, length: 5..120
        string :description, length: 0..255
        string :url, length: 0..255
      end
    end

    response :created do
      object :project, required: true do
        integer :id, required: true, range: (1..)
        string :name, required: true, length: 5..120
        string :description, length: 0..255
        string :url, length: 0..255
      end
    end

    response :bad_request do
      object :error, required: true do
        string :message, required: true, length: 1..255
      end
    end
  end
end
